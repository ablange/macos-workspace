---
title: macOS defaults policy
status: accepted
updated: 2026-09-05
---

# ADR 0004: macOS defaults policy

## Context

Roadmap M04 asks this repository to automate only macOS settings worth preserving. The workstation already has several Finder and Dock keys set; that observed state is evidence, not sufficient justification by itself. The README promised that Finder is restarted only when a Finder key actually changed. ADR 0001 already treats brittle or security-sensitive setup as documented, not automated.

## Decision

- Automate a key only when all of these hold: it is configured today and deliberately worth preserving on a fresh Mac; domain, key, and type semantics are understood; it is reversible via an inverse `defaults write` or System Settings; `defaults read` verifies it; any restart is Finder or Dock only.
- Use curated targeted writes. The automated set is six Finder keys (`AppleShowAllExtensions`, `FXPreferredViewStyle`, and the four Desktop volume-visibility keys) plus `com.apple.dock autohide`.
- Read the current value before writing. Write only on drift. Restart Finder or Dock at most once per run, and only when that group drifted.
- Distinguish an absent key from a failed read. `defaults read` exits 1 for both, so the script keys on its `does not exist` diagnostic: absent means write; any other failure means leave that key unchanged, print the diagnostic, continue with the other keys, and exit 1.
- Catch each write failure explicitly so `set -e` cannot skip the restart phase. A failed write prints the `defaults` diagnostic and the domain/key, leaves successful writes intact, continues with the remaining keys, and does not mark that write as a group change. Finder or Dock restarts only when at least one write in that group succeeded, or when `MACOS_RESTART` requested it.
- Attempt the Finder and Dock restarts independently and report both. A failed restart exits 1 but leaves the written preferences in place. Recovery is explicit: `MACOS_RESTART=finder|dock|finder,dock` requests a restart on an otherwise converged run. No marker file is kept between runs, and a normal converged run never restarts anything.
- Treat brittle, personal, or security-sensitive configuration as manual. Do not automate incidental state such as Dock `tilesize`.

Rejected alternatives: a defaults dump, unconditional writes, `defaults delete`, `-currentHost`, logout or reboot automation, a per-setting script architecture, automating incidental slider state, and a pending-restart marker file under `$HOME` (machine state the script would have to create and remove, for a case the retry variable handles without any).

## Consequences

- Adding a key is one `ensure_default` call plus a README bullet.
- Every automated key has a documented inverse.
- `make macos` is safe to rerun and stays limited to the intentionally selected preferences.
- A non-zero exit after writes means "written but not yet visible", "one key could not be read", or "one key could not be written"; the message names the fix, and rerunning never re-writes converged keys.
