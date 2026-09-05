#!/usr/bin/env bash
set -euo pipefail

if ! command -v defaults >/dev/null 2>&1; then
  echo "macos: defaults is not available." >&2
  echo "Then rerun: make macos" >&2
  exit 1
fi

# MACOS_RESTART is the explicit retry path when an earlier run wrote
# preferences but failed to restart Finder or Dock. Once the defaults
# have converged, a normal run has nothing to restart; this variable
# requests the restart anyway. Values: finder, dock, or both separated
# by a comma or space. It is validated before any preference is written.
finder_restart_requested=0
dock_restart_requested=0
while IFS= read -r token; do
  [ -n "$token" ] || continue
  case "$token" in
    finder) finder_restart_requested=1 ;;
    dock) dock_restart_requested=1 ;;
    *)
      echo "macos: MACOS_RESTART accepts finder and/or dock; got '$token'" >&2
      exit 1
      ;;
  esac
done <<EOF
$(printf '%s\n' "${MACOS_RESTART:-}" | tr -s ', ' '\n')
EOF

finder_changed=0
dock_changed=0
read_failures=0
write_failures=0

# Read one preference. Sets `current` and returns 0 when the key exists,
# 1 when defaults reports it absent, and 2 on any other failure. On
# failure the combined output is left in `current` for diagnostics; the
# expected "does not exist" message is not echoed.
read_default() {
  local domain="$1"
  local key="$2"
  local status=0

  current="$(defaults read "$domain" "$key" 2>&1)" || status=$?
  if [ "$status" -eq 0 ]; then
    return 0
  fi
  case "$current" in
    *"does not exist"*) return 1 ;;
    *) return 2 ;;
  esac
}

ensure_default() {
  local group="$1"
  local domain="$2"
  local key="$3"
  local type="$4"
  local value="$5"
  local current desired read_status=0 write_status=0 write_output

  read_default "$domain" "$key" || read_status=$?
  if [ "$read_status" -eq 2 ]; then
    echo "macos: cannot read $domain $key; leaving it unchanged" >&2
    if [ -n "$current" ]; then
      printf '%s\n' "$current" >&2
    fi
    read_failures=$((read_failures + 1))
    return 0
  fi
  if [ "$read_status" -eq 1 ]; then
    current=""
  fi

  case "$type" in
    bool)
      case "$value" in
        true) desired="1" ;;
        false) desired="0" ;;
        *) desired="$value" ;;
      esac
      ;;
    *)
      desired="$value"
      ;;
  esac

  if [ "$read_status" -eq 0 ] && [ "$current" = "$desired" ]; then
    echo "macos: $domain $key already $value"
    return 0
  fi

  write_output="$(defaults write "$domain" "$key" "-$type" "$value" 2>&1)" || write_status=$?
  if [ "$write_status" -ne 0 ]; then
    echo "macos: cannot write $domain $key" >&2
    if [ -n "$write_output" ]; then
      printf '%s\n' "$write_output" >&2
    fi
    write_failures=$((write_failures + 1))
    return 0
  fi
  if [ "$read_status" -eq 0 ]; then
    echo "macos: set $domain $key to $value (was $current)"
  else
    echo "macos: set $domain $key to $value (was unset)"
  fi

  case "$group" in
    finder) finder_changed=1 ;;
    dock) dock_changed=1 ;;
  esac
}

# Finder
# Always see real file types.
ensure_default finder NSGlobalDomain AppleShowAllExtensions bool true
# List view for new Finder windows.
ensure_default finder com.apple.finder FXPreferredViewStyle string Nlsv
# Internal volumes visible on the Desktop.
ensure_default finder com.apple.finder ShowHardDrivesOnDesktop bool true
# External volumes visible on the Desktop.
ensure_default finder com.apple.finder ShowExternalHardDrivesOnDesktop bool true
# Removable media visible on the Desktop.
ensure_default finder com.apple.finder ShowRemovableMediaOnDesktop bool true
# Mounted servers visible on the Desktop.
ensure_default finder com.apple.finder ShowMountedServersOnDesktop bool true

# Dock
# Keep editor and terminal screen space.
ensure_default dock com.apple.dock autohide bool true

# Keyboard
# Nothing is automated: no keyboard preference is set on this Mac.

# Screenshots
# Nothing is automated: no screenshot preference is set on this Mac.

# Restarts are attempted independently: a Finder failure never skips the
# Dock attempt. Failures are collected and reported once at the end.
restart_failed=""

if [ "$finder_changed" -eq 1 ] || [ "$finder_restart_requested" -eq 1 ]; then
  if [ "$finder_changed" -eq 1 ]; then
    echo "macos: restarting Finder"
  else
    echo "macos: restarting Finder (requested by MACOS_RESTART)"
  fi
  if ! killall Finder; then
    echo "macos: Finder restart failed" >&2
    restart_failed="${restart_failed:+$restart_failed,}finder"
  fi
else
  echo "macos: Finder unchanged; not restarted"
fi

if [ "$dock_changed" -eq 1 ] || [ "$dock_restart_requested" -eq 1 ]; then
  if [ "$dock_changed" -eq 1 ]; then
    echo "macos: restarting Dock"
  else
    echo "macos: restarting Dock (requested by MACOS_RESTART)"
  fi
  if ! killall Dock; then
    echo "macos: Dock restart failed" >&2
    restart_failed="${restart_failed:+$restart_failed,}dock"
  fi
else
  echo "macos: Dock unchanged; not restarted"
fi

echo "macos: input, appearance, and security/privacy settings are intentionally not automated"

exit_status=0
if [ "$read_failures" -ne 0 ]; then
  echo "macos: $read_failures preference(s) could not be read and were left unchanged; fix the error above and rerun make macos" >&2
  exit_status=1
fi
if [ "$write_failures" -ne 0 ]; then
  echo "macos: $write_failures preference(s) could not be written; successful writes are left intact; fix the error above and rerun make macos" >&2
  exit_status=1
fi
if [ -n "$restart_failed" ]; then
  echo "macos: preferences are written but not yet visible; retry the restart with: MACOS_RESTART=$restart_failed make macos" >&2
  exit_status=1
fi
exit "$exit_status"
