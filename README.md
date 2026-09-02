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

Homebrew is a prerequisite, installed by `make prerequisites` when missing. The Brewfile cannot install Homebrew, and it lists only intentional top-level tools, not everything `brew list` happens to show.

The clone never replaces `~/.bashrc` or rewrites `~/.gitconfig`. Shell integration is manual: the user adds a single `source` line. A later `git` target adds one safe, idempotent `include.path` for portable Git config. Machine-specific values stay in local files that this repository does not track.

## Homebrew

M01 is implemented. The root `Brewfile` is the intentional software contract: a hand-curated list of top-level formulae and casks, never generated with `brew bundle dump`. pyenv owns Python interpreters. Docker Desktop owns the container runtime, the `docker` CLI, and Compose.

- `make prerequisites` verifies Xcode Command Line Tools and installs Homebrew when it is missing.
- `make brew` installs missing declared packages with `brew bundle install --no-upgrade`. It does not proactively upgrade existing Brewfile packages. Installing a missing package may still upgrade a dependency that package requires. It never runs `bundle cleanup`, `autoremove`, or `--force`.

Homebrew Bundle attempts safe adoption of compatible existing applications; incompatible apps require manual migration (`brew install --cask --adopt <cask>`) and are never overwritten with `--force`. Adopting `docker-desktop` may cause Homebrew itself to request an admin password while relinking `/usr/local/bin` symlinks. Databricks trust is formula-scoped (`trusted: true` on `databricks/tap/databricks`) and recorded in `~/.homebrew/trust.json` by `brew bundle`. Application and cloud authentication stay manual.

The standalone Homebrew `docker` and `podman` formulae are not part of the intended contract. `astro` remains manual because its current Homebrew formula forces Podman ownership. Apps without a cask stay manual.

## One-time migration — review before running

These commands are **not** automated and **must not** be run as part of repository validation. Review them, then run them explicitly if you want this machine to match the M01 contract:

```bash
brew uninstall docker docker-completion
brew uninstall astro podman
make brew
```

Optional review (out of scope for `make brew`; do not automate):

- `coreutils` (present only as a dependency today)
- `tcl-tk` and `zlib` leaves
- unrelated Nix profile entries on `PATH`

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
- `prerequisites` — Xcode CLT and Homebrew
- `brew` — `brew bundle` from the Brewfile (install missing packages; no upgrade, no cleanup)

Planned:

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
3. Run `make prerequisites`, then `make brew`.
4. Follow the project roadmap from M02 onward for shell, Git, Python, defaults, and bootstrap.
5. Complete documented manual steps (auth, apps without a cask, GUI preferences).

## Roadmap

M00 (Repository Foundation) and M01 (Homebrew Workstation Baseline) are what this tree implements. M02 (shell configuration) is next. The authoritative roadmap lives outside this repository; knowledge files record durable architecture and decisions only.
