#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/python/version")"

if ! command -v pyenv >/dev/null 2>&1; then
  echo "pyenv is not available. Run 'make brew', open a new shell, then rerun: make python" >&2
  exit 1
fi

if ! command -v pipx >/dev/null 2>&1; then
  echo "pipx is not available. Run 'make brew', open a new shell, then rerun: make python" >&2
  exit 1
fi

if [ -d "$(pyenv root)/versions/$VERSION" ]; then
  echo "Python $VERSION already installed"
else
  echo "Installing Python $VERSION..."
  pyenv install --skip-existing "$VERSION"
fi

if [ "$(pyenv global)" = "$VERSION" ]; then
  echo "Python $VERSION is already the global pyenv version"
else
  echo "Setting global Python to $VERSION..."
  pyenv global "$VERSION"
fi

"$(pyenv prefix "$VERSION")/bin/python" --version

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "note: $HOME/.local/bin (pipx apps) is not on PATH yet; open a new shell after 'make shell'" ;;
esac
