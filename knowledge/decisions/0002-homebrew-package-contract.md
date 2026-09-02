---
title: Homebrew package contract
status: accepted
updated: 2026-09-01
---

# ADR 0002: Homebrew package contract

## Context

ADR 0001 established Homebrew plus a root Brewfile as the declarative package layer, pyenv as the Python owner, and the requirement that container tooling have a single owner. M00 shipped a comment-only Brewfile. This workstation already has Homebrew formulae, Docker Desktop, a Homebrew `docker` formula that shadows Desktop's CLI, Astronomer `astro` (which depends on Podman), and several GUI apps installed outside Homebrew. M01 selects the intentional top-level packages and the adoption, trust, and migration rules that keep `make brew` idempotent and non-destructive.

## Decision

- The Brewfile lists intentional top-level workstation dependencies only. It is hand-curated and is never generated with `brew bundle dump`.
- pyenv owns Python interpreters. No `python@X.Y` (or other Homebrew Python interpreter) formula is declared. Homebrew Pythons pulled in privately by tools such as `pipx` or `copier` are tolerated as implementation details and are never used as the workstation interpreter.
- Python build libraries (`openssl@3`, `readline`, `pkgconf`, `sqlite`, `xz`, and similar) are not declared merely because they are already present as dependencies. Leaves such as `tcl-tk` and `zlib` sit outside the contract and are review candidates, not silent removals.
- Docker Desktop owns the container runtime, the `docker` CLI, and Compose. The Brewfile declares `cask "docker-desktop"` and does not declare the `docker`, `docker-compose`, or `podman` formulae. Podman is not retained.
- `astro` stays a manual install. Its current Homebrew formula forces Podman ownership, which conflicts with Docker Desktop as the container owner.
- Cask migration uses Homebrew's documented `brew install --cask --adopt` when an existing app must be brought under Homebrew by hand. Homebrew Bundle's current automatic adoption of compatible existing apps is an implementation detail, not the repository's public contract. Incompatible apps require that manual adopt path and are never overwritten with `--force`. Apps without a cask stay manual.
- Databricks CLI trust is formula-scoped: `brew "databricks/tap/databricks", trusted: true`. There is no blanket third-party tap trust.
- `make brew` runs `brew bundle install --no-upgrade` and does not run `bundle cleanup` or `autoremove`. Existing Brewfile packages are not proactively upgraded; installing a missing package may still upgrade a dependency that package requires.
- One-time workstation migration (removing the shadowing `docker` formula, moving `astro` to a manual install, dropping unneeded `podman`) is reviewed and run separately. It is not automated by this repository.

## Consequences

- `make prerequisites` can install Homebrew; `make brew` can install missing declared packages without changing unrelated workstation state.
- Competing container CLIs are not part of the intended contract. Clearing the existing `docker` formula / `astro` / `podman` overlap is an explicit, reviewed migration.
- Formula-scoped Databricks trust is recorded by `brew bundle` in `~/.homebrew/trust.json`. Cloud authentication remains manual.
- Adopting `docker-desktop` may cause Homebrew to request an admin password while relinking `/usr/local/bin` Docker symlinks.
- Future package additions are reviewed into the Brewfile; `coreutils` stays out until a concrete workflow needs GNU tools.
