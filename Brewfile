# Hand-curated workstation package contract. Do not generate this file
# with `brew bundle dump`.
# pyenv owns Python interpreters; do not declare python@X.Y formulae.
# Docker Desktop owns the container runtime, docker CLI, and Compose.

# CLI fundamentals
brew "bash-completion"   # v1: system Bash is 3.2
brew "shellcheck"
brew "tree"
brew "wget"

# Git and GitHub
brew "gh"
brew "git-filter-repo"

# Python tooling  (pyenv owns interpreters; no python@X.Y here)
brew "pyenv"
brew "pyenv-virtualenv"
brew "pipx"
brew "copier"

# Data engineering
brew "duckdb"
brew "libpq"
brew "astronomer/tap/astro", args: ["without-podman"], trusted: true

# Cloud tooling
brew "awscli"
brew "databricks/tap/databricks", trusted: true

# GUI applications. Install the cask only when the bundle is absent
# from /Applications. Existing apps are left unmanaged and untouched;
# Homebrew Bundle must never adopt or mutate them.

# Containers  (Docker Desktop owns runtime, CLI, Compose)
cask "docker-desktop" unless File.exist?("/Applications/Docker.app")

# Developer applications
cask "cursor" unless File.exist?("/Applications/Cursor.app")
cask "dbeaver-community" unless File.exist?("/Applications/DBeaver.app")
cask "iterm2" unless File.exist?("/Applications/iTerm.app")

# Productivity
cask "chatgpt" unless File.exist?("/Applications/ChatGPT.app")
cask "google-chrome" unless File.exist?("/Applications/Google Chrome.app")
cask "microsoft-teams" unless File.exist?("/Applications/Microsoft Teams.app")
cask "rectangle" unless File.exist?("/Applications/Rectangle.app")
cask "zoom" unless File.exist?("/Applications/zoom.us.app")
