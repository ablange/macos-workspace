---
title: Repository architecture
status: active
updated: 2026-09-02
---

# Repository architecture

## Directory responsibilities

| Path | Role |
| --- | --- |
| `Makefile` | Human interface. Each target delegates to one script. |
| `Brewfile` | Declarative package layer. Populated in M01. |
| `scripts/` | Executable automation. `lint.sh`, `test.sh`, `prerequisites.sh`, `brew.sh`, and `git_pull.sh` exist today; later milestones add remaining installers and `doctor`. |
| `shell/` | Sourced Bash configuration (later milestone). Never sets strict-mode flags. |
| `git/` | Portable Git configuration (later milestone). |
| `docs/` | Manual setup that must not be automated (later milestone). |
| `knowledge/` | Durable architecture and decisions. Does not copy the roadmap. |

Directories are created only when they have content.

## Layering

Make is the entry point. Recipes contain no logic beyond invoking a script. Scripts call tools (`bash`, `brew`, `git`, `pyenv`). Humans run `make <target>`; agents do the same.

## Ownership boundaries

- **Repository:** tracked Brewfile, scripts, portable shell fragments, portable Git config, knowledge, and docs.
- **Machine-local files:** `~/.bashrc.local` and `~/.gitconfig.local` hold identity and host-specific values. They are not tracked.
- **User files we do not replace:** `~/.bashrc` and `~/.gitconfig`. The user adds a `source` line; Git uses `[include]`.
- **Manual steps:** brittle, proprietary, or security-sensitive setup stays in documentation.

## Constraints

- System `/bin/bash` is 3.2. No `globstar`, `mapfile`, associative arrays, or `${var,,}`.
- GNU Make is 3.81. No `.SHELLFLAGS`, `.ONESHELL`, `$(file ...)`, or `!=`.
- Never hard-code a Homebrew prefix. Use `brew --prefix` or `brew shellenv`.

## Eventual bootstrap sequence

This sequence is the target architecture. `help`, `lint`, `test`, `prerequisites`, `brew`, and `git_pull` are implemented. `git_pull` is a convenience target, not part of bootstrap.

```mermaid
flowchart LR
  prerequisites[prerequisites]
  brew[brew]
  shell[shell]
  git[git]
  python[python]
  macos[macos]
  doctor[doctor]
  prerequisites --> brew --> shell --> git --> python --> macos --> doctor
```

`bootstrap` will run that sequence and finish with `doctor`. `doctor` reports drift only; it does not mutate the machine.
