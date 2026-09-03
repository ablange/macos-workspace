#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_BASHRC="$REPO_ROOT/shell/bash/.bashrc"
REPO_BASHRC_D="$REPO_ROOT/shell/bash/.bashrc.d"

if [ ! -f "$REPO_BASHRC" ] || [ ! -d "$REPO_BASHRC_D" ]; then
  echo "shell: repository shell files are missing." >&2
  echo "Then rerun: make shell" >&2
  exit 1
fi

if ! /bin/bash -n "$REPO_BASHRC"; then
  echo "shell: failed to parse $REPO_BASHRC" >&2
  echo "Then rerun: make shell" >&2
  exit 1
fi

for fragment in "$REPO_BASHRC_D"/*.sh; do
  if [ ! -f "$fragment" ]; then
    echo "shell: no fragments in $REPO_BASHRC_D" >&2
    echo "Then rerun: make shell" >&2
    exit 1
  fi
  if ! /bin/bash -n "$fragment"; then
    echo "shell: failed to parse $fragment" >&2
    echo "Then rerun: make shell" >&2
    exit 1
  fi
done

if [ "${REPO_ROOT#"$HOME"/}" != "$REPO_ROOT" ]; then
  source_line="source \"\$HOME/${REPO_ROOT#"$HOME"/}/shell/bash/.bashrc\""
else
  source_line="source \"$REPO_BASHRC\""
fi

# Print the first argument of an active source/. line. Comments do not count.
active_source_arg() {
  local line="$1"
  local trimmed rest

  trimmed="${line#"${line%%[![:space:]]*}"}"
  case "$trimmed" in
    ''|\#*) return 1 ;;
  esac

  case "$trimmed" in
    source[[:space:]]*)
      rest="${trimmed#source}"
      ;;
    '.'[[:space:]]*)
      rest="${trimmed#.}"
      ;;
    *)
      return 1
      ;;
  esac

  rest="${rest#"${rest%%[![:space:]]*}"}"
  [ -n "$rest" ] || return 1

  case "$rest" in
    \"*)
      rest="${rest#\"}"
      printf '%s\n' "${rest%%\"*}"
      ;;
    \'*)
      rest="${rest#\'}"
      printf '%s\n' "${rest%%\'*}"
      ;;
    *)
      # First whitespace-delimited token. Intentional split.
      # shellcheck disable=SC2086
      set -- $rest
      printf '%s\n' "$1"
      ;;
  esac
}

file_has_active_source() {
  local file="$1"
  shift
  local line arg needle

  [ -f "$file" ] || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    arg="$(active_source_arg "$line")" || continue
    for needle in "$@"; do
      if [ "$arg" = "$needle" ]; then
        return 0
      fi
    done
  done < "$file"
  return 1
}

file_sources_other_workspace_bashrc() {
  local file="$1"
  local line arg

  [ -f "$file" ] || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    arg="$(active_source_arg "$line")" || continue
    case "$arg" in
      */shell/bash/.bashrc)
        return 0
        ;;
    esac
  done < "$file"
  return 1
}

user_bashrc="$HOME/.bashrc"
user_profile="$HOME/.bash_profile"
sourced=0

if [ "${REPO_ROOT#"$HOME"/}" != "$REPO_ROOT" ]; then
  rel="${REPO_ROOT#"$HOME"/}/shell/bash/.bashrc"
  # Tilde and $HOME needles are literal user-written forms, not expansions.
  # shellcheck disable=SC2088
  if file_has_active_source "$user_bashrc" "$REPO_BASHRC" "\$HOME/$rel" "~/$rel"; then
    sourced=1
  fi
elif file_has_active_source "$user_bashrc" "$REPO_BASHRC"; then
  sourced=1
fi

if [ "$sourced" -eq 1 ]; then
  echo "shell: ~/.bashrc sources $REPO_BASHRC"
else
  echo "shell: add this line to ~/.bashrc:"
  echo
  echo "$source_line"
fi

# Exact ~/.bashrc only; ~/.bashrc.local and comments are not integration.
# shellcheck disable=SC2088
if file_has_active_source "$user_profile" "~/.bashrc" "\$HOME/.bashrc" "$HOME/.bashrc"; then
  :
else
  echo "shell: warning: ~/.bash_profile does not source ~/.bashrc"
  echo "shell: warning: add this line to ~/.bash_profile:"
  echo
  echo "source ~/.bashrc"
fi

if [ "$sourced" -eq 0 ] && file_sources_other_workspace_bashrc "$user_bashrc"; then
  echo "shell: ~/.bashrc sources another shell/bash/.bashrc"
fi

if [ -f "$HOME/.bashrc.local" ]; then
  echo "shell: ~/.bashrc.local is present"
else
  echo "shell: ~/.bashrc.local is absent"
fi
