#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_GITCONFIG="$REPO_ROOT/git/.gitconfig"
REPO_IGNORE="$REPO_ROOT/git/ignore"
WANTED_INCLUDE="$REPO_ROOT/git/.gitconfig"

if ! command -v git >/dev/null 2>&1; then
  echo "git is not available." >&2
  echo "Install Xcode Command Line Tools, then rerun: make git" >&2
  exit 1
fi

if [ ! -f "$REPO_GITCONFIG" ]; then
  echo "git: missing $REPO_GITCONFIG" >&2
  echo "Then rerun: make git" >&2
  exit 1
fi

if ! git config --file "$REPO_GITCONFIG" --list >/dev/null; then
  echo "git: failed to parse $REPO_GITCONFIG" >&2
  echo "Then rerun: make git" >&2
  exit 1
fi

includes="$(git config --global --get-all include.path 2>/dev/null || true)"
have_current=0
stale=""

while IFS= read -r path; do
  [ -n "$path" ] || continue
  if [ "$path" = "$WANTED_INCLUDE" ]; then
    have_current=1
    continue
  fi
  case "$path" in
    */macos-workspace/git/.gitconfig)
      if [ -n "$stale" ]; then
        stale="$stale
$path"
      else
        stale="$path"
      fi
      ;;
  esac
done <<EOF
$includes
EOF

if [ -n "$stale" ]; then
  echo "git: existing macos-workspace include points elsewhere:"
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    echo "  $path"
  done <<EOF
$stale
EOF
  echo
  echo "Review/remove it before adding:"
  echo "  $WANTED_INCLUDE"
  echo "Then rerun: make git" >&2
  exit 1
fi

if [ "$have_current" -eq 1 ]; then
  echo "git: include.path already $WANTED_INCLUDE"
else
  git config --global --add include.path "$WANTED_INCLUDE"
  echo "git: added include.path $WANTED_INCLUDE"
fi

global_excludes="$(git config --global --includes --get core.excludesfile 2>/dev/null || true)"
system_excludes="$(git config --system --includes --get core.excludesfile 2>/dev/null || true)"
skip_link=0

if [ -n "$global_excludes" ]; then
  echo "git: core.excludesFile is set to $global_excludes (global); ~/.config/git/ignore is not consulted"
  skip_link=1
fi
if [ -n "$system_excludes" ]; then
  echo "git: core.excludesFile is set to $system_excludes (system); ~/.config/git/ignore is not consulted"
  skip_link=1
fi

link="${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"

if [ "$skip_link" -eq 0 ]; then
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$REPO_IGNORE" ]; then
    echo "git: $link already links to $REPO_IGNORE"
  elif [ -e "$link" ] || [ -L "$link" ]; then
    if [ -L "$link" ]; then
      echo "git: $link already exists and points to $(readlink "$link")"
    else
      echo "git: $link already exists"
    fi
  else
    mkdir -p "$(dirname "$link")"
    ln -s "$REPO_IGNORE" "$link"
    echo "git: linked $link -> $REPO_IGNORE"
  fi
fi

if git config --global --includes --get user.name >/dev/null 2>&1; then
  echo "git: user.name is set"
else
  echo "git: user.name is unset"
fi

if git config --global --includes --get user.email >/dev/null 2>&1; then
  echo "git: user.email is set"
else
  echo "git: user.email is unset"
fi

bs="$(git config --global --includes --get alias.bs 2>/dev/null || true)"
if [ "$bs" = "branch" ]; then
  echo "git: alias.bs is branch"
else
  echo "git: alias.bs is ${bs:-unset}"
fi

if [ -f "$HOME/.gitconfig.local" ]; then
  echo "git: ~/.gitconfig.local is present"
else
  echo "git: ~/.gitconfig.local is absent"
fi
