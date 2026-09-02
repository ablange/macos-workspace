---
title: Homebrew package contract
status: accepted
updated: 2026-09-01
---

# ADR 0002: Homebrew package contract

## Context

ADR 0001 established Homebrew plus a root Brewfile as the declarative package layer, pyenv as the Python owner, and the requirement that container tooling have a single owner. M00 shipped a comment-only Brewfile. This workstation already has Homebrew formulae, Docker Desktop, a Homebrew `docker` formula that shadows Desktop's CLI, Astronomer `astro` (which depends on Podman), and several GUI apps installed outside Homebrew. M01 selects the intentional top-level packages and the trust, migration, and GUI-cask rules that keep `make brew` idempotent and non-destructive.

Real-machine testing showed that Homebrew Bundle's automatic cask adoption is not reliable enough for this project: adopting already-installed apps can fail on `chmod` or `xattr` (`Operation not permitted`) and a failed Cursor adoption attempted to remove `/Applications/Cursor.app`. `make brew` must not depend on that behavior.

## Decision

- The Brewfile lists intentional top-level workstation dependencies only. It is hand-curated and is never generated with `brew bundle dump`.
- pyenv owns Python interpreters. No `python@X.Y` (or other Homebrew Python interpreter) formula is declared. Homebrew Pythons pulled in privately by tools such as `pipx` or `copier` are tolerated as implementation details and are never used as the workstation interpreter.
- Python build libraries (`openssl@3`, `readline`, `pkgconf`, `sqlite`, `xz`, and similar) are not declared merely because they are already present as dependencies. Leaves such as `tcl-tk` and `zlib` sit outside the contract and are review candidates, not silent removals.
- Docker Desktop owns the container runtime, the `docker` CLI, and Compose. The Brewfile declares `cask "docker-desktop"` and does not declare the `docker`, `docker-compose`, or `podman` formulae. Podman is not retained.
- `astro` is declared as `brew "astronomer/tap/astro", args: ["without-podman"], trusted: true`. The Astronomer tap supports skipping Podman so Docker Desktop remains the sole container runtime. The Homebrew-core `astro` formula is not declared: it does not accept `--without-podman` and would pull Podman.
- Existing GUI applications are left unmanaged and untouched. The Brewfile declares each GUI cask only when the corresponding application is absent from `/Applications`. Homebrew installs the cask on a fresh Mac and leaves an already-installed app completely alone. `make brew` never passes `--adopt` or `--force`, and it never adopts or mutates an existing GUI app. Apps without a cask stay manual.
- Third-party formula trust is formula-scoped: `trusted: true` on `databricks/tap/databricks` and `astronomer/tap/astro`. There is no blanket third-party tap trust.
- `make brew` runs `brew bundle install --no-upgrade` and does not run `bundle cleanup`, `autoremove`, `--force`, or `--adopt`. Existing Brewfile packages are not proactively upgraded; installing a missing package may still upgrade a dependency that package requires.
- One-time workstation migration (removing the shadowing `docker` formula, replacing Homebrew-core `astro` plus `podman` with the Astronomer tap formula, then `make brew`) is reviewed and run separately. It is not automated by this repository. Documented uninstalls set `HOMEBREW_NO_AUTOREMOVE=1`; leftover dependencies are inspected with `brew autoremove --dry-run` rather than removed automatically.

## Consequences

- `make prerequisites` can install Homebrew; `make brew` can install missing declared packages without changing unrelated workstation state.
- Competing container CLIs are not part of the intended contract. Clearing the existing `docker` formula / Homebrew-core `astro` / `podman` overlap is an explicit, reviewed migration.
- Formula-scoped Databricks and Astronomer trust is recorded by `brew bundle` in `~/.homebrew/trust.json`. Cloud authentication remains manual.
- Already-installed GUI apps stay outside Homebrew management. `make brew` does not adopt them, so Homebrew will not chmod, xattr, or replace those bundles.
- Future package additions are reviewed into the Brewfile; `coreutils` stays out until a concrete workflow needs GNU tools.
