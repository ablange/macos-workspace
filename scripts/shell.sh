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

user_bashrc="$HOME/.bashrc"
user_profile="$HOME/.bash_profile"
sourced=0

if [ -f "$user_bashrc" ]; then
  if grep -Fq "$REPO_BASHRC" "$user_bashrc"; then
    sourced=1
  fi
  if [ "${REPO_ROOT#"$HOME"/}" != "$REPO_ROOT" ]; then
    rel="${REPO_ROOT#"$HOME"/}/shell/bash/.bashrc"
    # The tilde is a literal needle for a user-written ~/path, not an expansion.
    # shellcheck disable=SC2088
    if grep -Fq "\$HOME/$rel" "$user_bashrc" || grep -Fq "~/$rel" "$user_bashrc"; then
      sourced=1
    fi
  fi
fi

if [ "$sourced" -eq 1 ]; then
  echo "shell: ~/.bashrc sources $REPO_BASHRC"
else
  echo "shell: add this line to ~/.bashrc:"
  echo
  echo "$source_line"
fi

profile_ok=0
if [ -f "$user_profile" ]; then
  if grep -Eq '(^|[[:space:]])(\.|source)[[:space:]]+.*\.bashrc' "$user_profile"; then
    profile_ok=1
  fi
fi

if [ "$profile_ok" -eq 0 ]; then
  echo "shell: warning: ~/.bash_profile does not source ~/.bashrc"
  echo "shell: warning: add this line to ~/.bash_profile:"
  echo
  echo "source ~/.bashrc"
fi

if [ -f "$user_bashrc" ] && [ "$sourced" -eq 0 ] && grep -Fq 'shell/bash/.bashrc' "$user_bashrc"; then
  echo "shell: ~/.bashrc sources another shell/bash/.bashrc"
fi

if [ -f "$HOME/.bashrc.local" ]; then
  echo "shell: ~/.bashrc.local is present"
else
  echo "shell: ~/.bashrc.local is absent"
fi
