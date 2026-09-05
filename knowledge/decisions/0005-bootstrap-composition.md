---
title: Bootstrap composition
status: accepted
updated: 2026-09-05
---

# ADR 0005: Bootstrap composition

## Context

M00–M05 shipped independent Make targets for automated workstation setup: `prerequisites`, `brew`, `shell`, `git`, `python`, and `macos`. Those targets have a required dependency order. A fresh Mac where `prerequisites` installs Homebrew leaves `brew` off `PATH` until the user follows the installer's Next steps. Earlier ADRs (0001, 0003) expected a later `doctor` target for drift reporting.

## Decision

- Implement `bootstrap` as a sequential recipe of controlled `$(MAKE)` calls to the existing setup targets, in this order: `prerequisites`, `brew`, `shell`, `git`, `python`, `macos`.
- Do not declare those targets as sibling prerequisites of `bootstrap`. GNU Make does not guarantee the order in which sibling prerequisites are built.
- Do not add `.NOTPARALLEL`. Removing concurrency does not encode prerequisite-to-prerequisite order and would disable parallelism for unrelated targets. Recipe lines of one target already run sequentially, including under `make -j`.
- Document one rerun point: if `prerequisites` just installed Homebrew, the user follows the installer's Next steps, opens a new shell, and reruns `make bootstrap`. No new PATH-propagation mechanism is added.
- Drop `doctor` and `status` from project scope. This ADR supersedes the `doctor` expectations in ADR 0001 and ADR 0003 without editing those files.
- Add no bootstrap state, rollback, or drift-reporting system.

Rejected alternatives: `bootstrap: prerequisites brew shell git python macos`, a global `.NOTPARALLEL`, `scripts/bootstrap.sh`, and shipping `doctor` or `status`.

## Consequences

- `make bootstrap` is orchestration only. Existing targets stay independently runnable and unchanged.
- A non-zero child Make stops the remaining recipe lines.
- Fresh-Homebrew recovery is a documented rerun, not extra automation.
- Tests assert composition with `make -n bootstrap` and never execute the setup targets for real.
