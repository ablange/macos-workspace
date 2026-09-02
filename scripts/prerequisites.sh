#!/usr/bin/env bash
set -euo pipefail

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are not installed." >&2
  echo "Install them with:" >&2
  echo "  xcode-select --install" >&2
  echo "Then rerun: make prerequisites" >&2
  exit 1
fi

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
  echo "Homebrew version:"
  brew --version
  echo "Homebrew prefix: $(brew --prefix)"
  exit 0
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
  echo "Homebrew version:"
  brew --version
  echo "Homebrew prefix: $(brew --prefix)"
  exit 0
fi

echo "Homebrew was installed but 'brew' is not on PATH." >&2
echo "Follow the installer's Next steps to add the brew shellenv line, then rerun: make prerequisites" >&2
exit 1
