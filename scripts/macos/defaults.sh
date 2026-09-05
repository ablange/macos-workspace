#!/usr/bin/env bash
set -euo pipefail

if ! command -v defaults >/dev/null 2>&1; then
  echo "macos: defaults is not available." >&2
  echo "Then rerun: make macos" >&2
  exit 1
fi

finder_changed=0
dock_changed=0

ensure_default() {
  local group="$1"
  local domain="$2"
  local key="$3"
  local type="$4"
  local value="$5"
  local current desired

  current="$(defaults read "$domain" "$key" 2>/dev/null || true)"

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

  if [ "$current" = "$desired" ]; then
    echo "macos: $domain $key already $value"
    return 0
  fi

  defaults write "$domain" "$key" "-$type" "$value"
  if [ -n "$current" ]; then
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

if [ "$finder_changed" -eq 1 ]; then
  echo "macos: restarting Finder"
  killall Finder
else
  echo "macos: Finder unchanged; not restarted"
fi

if [ "$dock_changed" -eq 1 ]; then
  echo "macos: restarting Dock"
  killall Dock
else
  echo "macos: Dock unchanged; not restarted"
fi

echo "macos: input, appearance, and security/privacy settings are intentionally not automated"
