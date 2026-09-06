# Maintain the workstation repository

Give a coding agent this prompt when the Mac has changed and the repository should catch up. The repository stays the source of truth; the machine is evidence, not a snapshot to dump.

The prompt is read-only against the machine and stops for approval before editing. Run it from the repository root with a clean working tree.

```text
You are maintaining my fork of `macos-workspace`, the repository that
holds the intentional parts of my macOS developer workstation.

The repository is the source of truth. The Mac is evidence of what may
have drifted since it was last updated. Find the drift, decide what is
deliberate and reusable, and persist only that. Do not snapshot the
machine.

Context from me (may be empty): [what changed on the Mac recently]

## Ground rules

- Be read-only against the machine: no installs, upgrades,
  `defaults write`, `brew bundle`, or edits outside the repository.
- Follow `AGENTS.md` throughout.
- Do not introduce a dotfiles framework, inventory system, sync
  mechanism, or configuration-management platform.
- Do not edit the repository until I approve the plan in Phase 3.
- Leave changes uncommitted for my review.

## Phase 1: Understand the repository

Confirm the working tree is clean; if not, tell me and stop. Read
`README.md`, `AGENTS.md`, `Brewfile`, `Makefile`, `scripts/`,
`shell/`, `git/`, `python/`, `docs/` (especially
`docs/manual-setup.md`), `knowledge/decisions/`, and the tests. Note
what the repository owns, what it deliberately leaves manual, and how
each kind of configuration is expressed.

## Phase 2: Inspect the machine

Use read-only commands, for example `brew leaves`,
`brew list --cask`, `mas list`, `ls /Applications ~/Applications`,
`defaults read <domain> <key>` for keys the repository manages or my
context mentions, and `git config --global --list` plus the live
shell/Git/Python files compared against what the repository provides.

Compare in both directions: things on the machine the repository does
not know about, and things the repository manages that are missing or
no longer match. If something looks like a credential, note that it
exists and do not reproduce its value.

## Phase 3: Propose, then stop

List every candidate change with the evidence, a classification, a
proposed action (add, update, remove, document in
`docs/manual-setup.md`, or ignore), and one line on why.

- Intentional: I would want it on a fresh Mac; it is stable; it is a
  leaf tool, not a dependency; it is a setting I chose on purpose.
- Incidental: transitive dependencies, one-off or experimental tools,
  caches, per-project tooling, installer side effects, ephemeral or
  machine-specific values.
- Unsure: default to excluding, and say what would resolve it.

Then stop and wait for approval. If nothing should change, say so.

## Phase 4: Apply approved changes

- Keep the `Brewfile` hand-curated. Do not use `brew bundle dump` or
  add transitive dependencies or temporary tools. Preserve the
  existing ownership rules for Python, Docker Desktop, and
  applications.
- Automate only macOS preferences that are stable, intentional, and
  useful to restore, using the `ensure_default` pattern in
  `scripts/macos/defaults.sh`, with the inverse documented in the
  README. Brittle, security- or privacy-sensitive, or rarely changed
  preferences go in `docs/manual-setup.md`. Do not expand the
  Finder/Dock restart policy without a strong architectural reason.
- For shell, Git, Python, and manual configuration, follow the
  existing architecture rather than adding a mechanism.

For each change: make the smallest edits that express it; update
tests when the contract changes and docs when user-visible behavior
changes; add an architecture decision only for a genuine architectural
decision; run `make lint test` and fix failures within scope.

## Phase 5: Review and report

Check the diff for machine-specific values (username, hostname, home
paths, serial numbers), secrets, destructive behavior, and unnecessary
complexity. Then report what changed by file, what you saw but
deliberately did not persist and why, and anything that still needs a
decision from me.
```
