# Maintain the workstation repository

Give a coding agent this prompt when the Mac has changed and the repository should catch up. The repository stays the source of truth; the machine is evidence, not a snapshot to dump.

```text
You are maintaining my fork of `macos-workspace`.

The repository is the source of truth for the intentional parts of my
macOS developer workstation.

First inspect the current repository, including:

- `README.md`
- `AGENTS.md`
- `Brewfile`
- `Makefile`
- `scripts/`
- `shell/`
- `git/`
- `python/`
- `docs/`
- `knowledge/decisions/`
- tests

Then inspect the current Mac using read-only commands where practical
and identify workstation configuration that may have changed since the
repository was last updated.

The goal is not to snapshot the machine. Persist only deliberate,
reusable workstation configuration that belongs on a future Mac.

For software:

- Compare relevant installed Homebrew formulae, Homebrew casks, and
  applications with the `Brewfile`.
- Do not use `brew bundle dump`.
- Do not add transitive dependencies or incidental/temporary tools.
- Keep the `Brewfile` hand-curated.
- Preserve the repository's existing ownership rules for Python,
  Docker Desktop, and applications.

For macOS preferences:

- Consider only settings that are stable, intentional, useful to
  restore, and appropriate for this repository.
- Follow the existing `ensure_default` pattern in
  `scripts/macos/defaults.sh`.
- Document the inverse setting in the README.
- Do not automate brittle, security-sensitive, privacy-sensitive, or
  rarely changed preferences. Put those in `docs/manual-setup.md` when
  appropriate.
- Do not expand the current Finder/Dock restart policy without a
  strong architectural reason.

For shell, Git, Python, and manual configuration, follow the existing
repository architecture rather than introducing a new mechanism.

Before editing, show me the candidate changes you believe should be
persisted and distinguish intentional configuration from incidental
machine state.

For approved changes:

1. Make the smallest necessary repository edits.
2. Update tests when the repository contract changes.
3. Update documentation when user-visible behavior changes.
4. Add an architecture decision only if an actual architectural
   decision is being introduced.
5. Run `make lint test`.
6. Review the final diff for accidental machine-specific values,
   secrets, destructive behavior, or unnecessary complexity.

Follow `AGENTS.md` throughout. Do not introduce a generic dotfiles
framework, inventory system, synchronization mechanism, or
configuration-management platform.
```
