---
title: Workstation bootstrap architecture
status: accepted
updated: 2026-09-01
---

# ADR 0001: Workstation bootstrap architecture

## Context

This repository bootstraps one real Mac. The machine already has Homebrew, a mix of formulae and manually installed GUI apps, pyenv-managed Python, and hand-maintained shell and Git config. The system `/bin/bash` is 3.2 and GNU Make is Apple's 3.81. The bootstrap must be understandable, idempotent, and safe to re-run without replacing the user's existing `~/.bashrc` or appending to `~/.gitconfig`.

## Decision

- Use Homebrew plus a root `Brewfile` as the declarative package layer, Bash scripts for automation, Make as the human interface, and pyenv for Python versions.
- Homebrew is a prerequisite, installed by a prerequisites script when that milestone lands, not by the Brewfile.
- pyenv owns Python versions. Homebrew does not install or manage Python for this workstation.
- Container tooling must have clear ownership and must not leave competing CLIs on `PATH`. The concrete choice among Docker Desktop, the Docker formula, and Podman is an M01 decision.
- Brittle, proprietary, or security-sensitive setup is documented, not automated.
- Tests never mutate the machine. A later `doctor` target inspects the machine and only reports.
- System Bash 3.2 and GNU Make 3.81 are the compatibility floor.

Rejected alternatives: Nix, Ansible, chezmoi or other dotfiles frameworks, and Homebrew-managed Python.

This ADR does not select formulae, casks, taps, cask-adoption behavior, or a container runtime. Those decisions belong to M01 and will be made and verified there.

## Consequences

- M00 can ship a working `help` / `lint` / `test` interface and a comment-only Brewfile without installing anything.
- Later milestones add one Make target and one script at a time, without changing this layering.
- Scripts must stay Bash 3.2 compatible; lint parses with `/bin/bash -n` and cannot catch runtime-only incompatibilities.
- Agents and humans use `source` / `[include]` indirection instead of rewriting user files.
- Prefix portability is required: never hard-code `/opt/homebrew`.
