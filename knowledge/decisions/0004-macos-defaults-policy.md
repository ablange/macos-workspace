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
- Treat brittle, personal, or security-sensitive configuration as manual. Do not automate incidental state such as Dock `tilesize`.

Rejected alternatives: a defaults dump, unconditional writes, `defaults delete`, `-currentHost`, logout or reboot automation, a per-setting script architecture, and automating incidental slider state.

## Consequences

- Adding a key is one `ensure_default` call plus a README bullet.
- Every automated key has a documented inverse.
- `make macos` is safe to rerun and stays limited to the intentionally selected preferences.
