---
title: Repository architecture
status: active
updated: 2026-09-05
---

# Repository architecture

## Directory responsibilities

| Path | Role |
| --- | --- |
| `Makefile` | Human interface. Leaf targets each delegate to one script. `bootstrap` is a sequential recipe of those targets. |
| `Brewfile` | Declarative package layer. |
| `scripts/` | Executable automation. `lint.sh`, `test.sh`, `prerequisites.sh`, `brew.sh`, `git_pull.sh`, `shell.sh`, `git.sh`, `python.sh`, and `macos/defaults.sh`. |
| `python/` | Pinned workstation Python version (`python/version`). |
| `shell/` | Sourced Bash configuration. `shell/bash/.bashrc` loads `shell/bash/.bashrc.d/{0-setup,1-git,2-pyenv,3-ps1}.sh` then `~/.bashrc.local`. `0-setup.sh` holds aliases and adds `$HOME/.local/bin` to `PATH`. Never sets strict-mode flags. |
| `git/` | Portable Git configuration. `git/.gitconfig`, `git/.gitconfig.local.example`, and `git/ignore`. |
| `docs/` | Manual setup that must not be automated ([docs/manual-setup.md](../../docs/manual-setup.md)) and reusable agent prompts ([docs/prompts/maintain-workspace.md](../../docs/prompts/maintain-workspace.md)). |
| `.github/workflows/` | CI. Runs `make lint test` only. |
| `knowledge/` | Durable architecture and decisions. Does not copy the roadmap. |

Directories are created only when they have content.

## Layering

Make is the entry point. Recipes contain no logic beyond invoking a script. Scripts call tools (`bash`, `brew`, `git`, `pyenv`). Humans run `make <target>`; agents do the same.

## Ownership boundaries

- **Repository:** tracked Brewfile, scripts, portable shell fragments, portable Git config, `git/ignore`, knowledge, and docs.
- **Machine-local files:** `~/.bashrc.local` and `~/.gitconfig.local` hold identity and host-specific values. They are not tracked.
- **User files we do not replace:** `~/.bashrc` and `~/.gitconfig`. The user adds a `source` line; Git uses `[include]`.
- **Linked ignore:** `git/ignore` (repository) is linked from `~/.config/git/ignore` (machine, symlink created only when absent).
- **Manual steps:** brittle, proprietary, or security-sensitive setup stays in documentation.
- **pyenv machine state:** `~/.pyenv/version` and `~/.pyenv/versions/` are written only by pyenv via `make python`. pipx's executable path comes from `0-setup.sh`, not `pipx ensurepath`.

## Constraints

- System `/bin/bash` is 3.2. No `globstar`, `mapfile`, associative arrays, or `${var,,}`.
- GNU Make is 3.81. No `.SHELLFLAGS`, `.ONESHELL`, `$(file ...)`, or `!=`.
- Never hard-code a Homebrew prefix. Use `brew --prefix` or `brew shellenv`.

## Bootstrap sequence

`bootstrap` runs `prerequisites`, `brew`, `shell`, `git`, `python`, then `macos` as sequential `$(MAKE)` calls and stops at the first failure; `git_pull` is a maintainer convenience and is not part of that sequence.

```mermaid
flowchart LR
  prerequisites[prerequisites]
  brew[brew]
  shell[shell]
  git[git]
  python[python]
  macos[macos]
  prerequisites --> brew --> shell --> git --> python --> macos
```
