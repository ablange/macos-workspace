#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not available. Run 'make prerequisites' first." >&2
  exit 1
fi

brew bundle install --no-upgrade --file "$REPO_ROOT/Brewfile"
