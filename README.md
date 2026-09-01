# macos-workspace

Opinionated bootstrap for one real Mac. This repository is public and specific: it records how this workstation is meant to be restored, not a generic dotfiles framework.

## What it owns

- Homebrew and a root `Brewfile` as the declarative package layer
- Bash fragments sourced from the clone
- Portable Git configuration, included rather than appended
- Python versions via pyenv (not Homebrew)
- A small, reversible set of macOS defaults
- Documentation for setup that should stay manual

## What it does not own

- Nix, Ansible, MDM, or any other configuration-management stack
- Cross-platform support
- A dotfiles framework
- Secrets or tokens
- Project IDE configuration (`.cursor/`, `.vscode/`, `*.code-workspace`)
- User identity (`user.name`, `user.email`)
- Cloud authentication (`gh`, `aws`, `databricks`, and similar logins)

## Installation philosophy

Homebrew is a prerequisite. The Brewfile cannot install Homebrew, and it lists only intentional top-level tools, not everything `brew list` happens to show.

The clone never replaces `~/.bashrc` or rewrites `~/.gitconfig`. The user adds a single `source` line and a single Git `include`. Machine-specific values stay in local files that this repository does not track.

## Homebrew

Homebrew must already be installed (or installed by a later `prerequisites` script). The root `Brewfile` is the package contract. In M00 it is a placeholder comment only; package selection is M01.

## Bash

When Bash configuration lands, add one line to the existing `~/.bashrc`:

```bash
source "$HOME/<clone-location>/macos-workspace/shell/bash/.bashrc"
```

The path depends on where the repository is cloned. Use `~/.bashrc.local` for machine-specific shell config. This repository never replaces `~/.bashrc`.

## Git

Portable Git settings live in the repository. Identity and other machine-specific values live in a local include file. Scripts add a single idempotent `include.path` after checking whether it is already present. They never append to `~/.gitconfig`.

## Python

pyenv owns Python versions. Homebrew does not install or manage Python for this workstation.

## macOS defaults

Later automation will change only defaults that are reversible and understood. No Gatekeeper changes. Finder is restarted only when a Finder key actually changed.

## Manual configuration

Brittle, proprietary, or security-sensitive setup is documented, not automated: app sign-ins, cloud auth, and tools with no Homebrew cask.

## Make targets

Implemented:

- `help` — list targets
- `lint` — static checks
- `test` — repository invariant tests

Planned (not implemented in M00):

- `prerequisites` — Xcode CLT and Homebrew
- `brew` — `brew bundle` from the Brewfile
- `shell` — print the Bash `source` line; never edit `~/.bashrc`
- `git` — idempotent `include.path` for portable Git config
- `python` — pyenv default version and `pipx ensurepath`
- `macos` — curated, reversible defaults
- `bootstrap` — run the above in order, then `doctor`
- `doctor` — report-only drift checks
- `status` — terse summary

## Fresh-Mac workflow

1. Clone this repository.
2. Confirm `make help`, `make lint`, and `make test` succeed.
3. Follow the project roadmap from M01 onward for packages, shell, Git, Python, defaults, and bootstrap.
4. Complete documented manual steps (auth, apps without a cask, GUI preferences).

## Roadmap

M00 (Repository Foundation) is what this tree implements. M01 (Homebrew package selection) is next. The authoritative roadmap lives outside this repository; knowledge files record durable architecture and decisions only.
