---
title: Shell and Git indirection
status: accepted
updated: 2026-09-02
---

# ADR 0003: Shell and Git indirection

## Context

This workstation already had a working Bash setup in another repository and a hand-maintained `~/.gitconfig`. M02 moves that shell configuration into this clone and adds portable Git settings without a dotfiles framework, without rewriting user files, and without putting identity or secrets in Git.

## Decision

- Integrate by indirection. The user adds one `source` line to `~/.bashrc`. `make git` adds one `include.path` to `~/.gitconfig`. The repository does not edit or replace `~/.bashrc`, and it never rewrites unrelated Git configuration.
- Keep portable configuration in the repository (`shell/`, `git/`) and machine-local values in `~/.bashrc.local` and `~/.gitconfig.local`. Those local files are untracked.
- Load Bash from ordered fragments, then `~/.bashrc.local` last so the machine can override the portable baseline. Adopt the existing mini-data-stack-hedge-fund fragments rather than redesigning them. Git completion and the branch prompt come from Xcode Command Line Tools helper files when present, with `~/.git-completion.bash` and `~/.git-prompt.sh` as fallback, so a fresh Mac does not depend on copied home files.
- Integrate Git safely: one `include.path`, a symlink at Git's default XDG ignore path created only when that path is absent, no `core.excludesFile` write, and stale macos-workspace includes reported rather than removed.
- Keep `make shell` read-only. A missing `source` line is the setup case and exits 0. Drift reporting belongs to `make doctor`.

Rejected alternatives: editing `~/.bashrc`, writing `core.excludesFile`, a `*.local` wildcard ignore, and dotfiles or prompt frameworks.

## Consequences

- A fresh Mac can print the Bash integration line, add a single Git include, and get Git completion plus the branch prompt from Command Line Tools, without destroying existing user configuration.
- Identity, credentials, and other host-specific values stay outside the repository.
- Moving the clone leaves a stale include and possibly a dangling ignore symlink. Both are reported; the user repairs them by hand.
- Later milestones can add `doctor` checks for shell and Git drift without changing this ownership model.
