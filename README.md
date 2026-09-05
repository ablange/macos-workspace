# macOS Workspace

Opinionated, idempotent bootstrap for one real Mac. Homebrew + Brewfile + Bash + pyenv + Make; nothing else. This repository records how this workstation is meant to be restored, not a generic dotfiles framework.

## What it manages

- **Homebrew.** A hand-curated root `Brewfile`, never generated with `brew bundle dump`. `make brew` runs `brew bundle install --no-upgrade`. It does not proactively upgrade existing Brewfile packages, and it never runs `bundle cleanup`, `autoremove`, `--force`, or `--adopt`. Installing a missing package may still upgrade a dependency that package requires. GUI casks are gated on `/Applications`; existing GUI applications are left unmanaged and untouched. Third-party trust is formula-scoped (`trusted: true` on `databricks/tap/databricks` and `astronomer/tap/astro`) and recorded by `brew bundle` in `~/.homebrew/trust.json`. Docker Desktop owns the container runtime, the `docker` CLI, and Compose. The standalone Homebrew `docker` and `podman` formulae are not declared. `astro` comes from the Astronomer tap with `--without-podman`.
- **Bash.** Fragments under `shell/bash/` are sourced from the clone. `shell/bash/.bashrc` loads `.bashrc.d/{0-setup,1-git,2-pyenv,3-ps1}.sh`, then `~/.bashrc.local` last. `make shell` prints the one `source` line to add to `~/.bashrc` and never edits that file.
- **Git.** Portable settings live in `git/.gitconfig` and are pulled in through one `include.path`. That file includes `~/.gitconfig.local` last, so machine-local values win. `make git` adds the include only when this clone's path is not already present; it never appends blindly and never removes existing keys. Global ignore patterns live in `git/ignore`. `make git` symlinks `~/.config/git/ignore` to that file only when the path is absent, and it does not write `core.excludesFile`.
- **Python.** pyenv owns interpreters. The pin is `python/version`. `make python` installs that version if it is missing and sets `pyenv global`. It never uninstalls versions, upgrades other interpreters, installs packages, creates virtualenvs, or edits shell files. pipx is a Brewfile package; `0-setup.sh` adds `~/.local/bin` to `PATH`.
- **macOS defaults.** `make macos` applies seven reversible Finder/Dock preferences. It reads each key first and writes only when the current value differs. Finder or Dock is restarted only when a key in that group changed.

  Finder (restarted only if one of these changed):

  - `NSGlobalDomain AppleShowAllExtensions` (`-bool true`) — always see real file types. Inverse: `-bool false`.
  - `com.apple.finder FXPreferredViewStyle` (`-string Nlsv`) — list view for new Finder windows. Inverse: another view style such as `icnv`.
  - `com.apple.finder ShowHardDrivesOnDesktop` (`-bool true`) — internal volumes on the Desktop. Inverse: `-bool false`.
  - `com.apple.finder ShowExternalHardDrivesOnDesktop` (`-bool true`) — external volumes on the Desktop. Inverse: `-bool false`.
  - `com.apple.finder ShowRemovableMediaOnDesktop` (`-bool true`) — removable media on the Desktop. Inverse: `-bool false`.
  - `com.apple.finder ShowMountedServersOnDesktop` (`-bool true`) — mounted servers on the Desktop. Inverse: `-bool false`.

  Dock (restarted only if this changed):

  - `com.apple.dock autohide` (`-bool true`) — keep editor and terminal screen space. Inverse: `-bool false`.

  Apply an inverse with `defaults write` and restart Finder or Dock, or use Finder / System Settings. If a restart fails after a write, retry with `MACOS_RESTART=finder make macos`, `MACOS_RESTART=dock make macos`, or `MACOS_RESTART=finder,dock make macos`. The variable only adds a restart; it never writes. Input, appearance, and security/privacy settings are not automated.

## Bootstrap a Mac

```bash
git clone <this-repository> macos-workspace
cd macos-workspace
make bootstrap
```

Then complete [docs/manual-setup.md](docs/manual-setup.md).

`make bootstrap` is a thin Makefile composition. It runs `prerequisites`, `brew`, `shell`, `git`, `python`, and `macos` in that order as sequential `$(MAKE)` calls, and it stops at the first failure. It does not run `git_pull`. It does not edit `~/.bashrc`. Git integration is the existing `make git` behavior (one `include.path` plus the global-ignore symlink). It does not perform the remaining steps in [docs/manual-setup.md](docs/manual-setup.md).

If `prerequisites` just installed Homebrew, follow the installer's Next steps, open a new shell, and rerun `make bootstrap`.

`make shell` never edits `~/.bashrc`. Add the line it prints, then open a new shell:

```bash
source "$HOME/<clone-location>/macos-workspace/shell/bash/.bashrc"
```

The path depends on where the repository is cloned. `~/.bashrc` is not replaced. macOS Terminal opens login shells, so `~/.bash_profile` should also `source ~/.bashrc`.

## Make targets

- `help` — Show available targets
- `lint` — Run static checks
- `test` — Run repository invariant tests
- `prerequisites` — Verify Xcode CLT and install Homebrew if missing
- `brew` — Install missing Brewfile packages (no proactive upgrade or cleanup)
- `git_pull` — Refresh local main after a PR merge
- `shell` — Print the Bash source line to add; never edits ~/.bashrc
- `git` — Add one idempotent include.path and link the global ignore file
- `python` — Install the pinned pyenv Python if missing and set pyenv global
- `macos` — Apply curated, reversible Finder/Dock defaults; restarts only on change
- `bootstrap` — Run automated workstation setup in dependency order

`git_pull` is a maintainer convenience: it checks out `main`, pulls `origin main`, then prunes remote-tracking refs (`git fetch -p`). `lint` and `test` never touch the machine.

## Manual setup

A few intentionally manual steps remain after `make bootstrap`: Git identity, optional local Bash configuration, GitHub and cloud authentication, Docker Desktop first run, and Rectangle Accessibility. See [docs/manual-setup.md](docs/manual-setup.md). That file is the single checklist; it is not duplicated here.

## Machine-local identity and secrets

`~/.bashrc.local` and `~/.gitconfig.local` hold identity and host-specific values. Tracked `.example` files show the shape; the real files are never tracked (`.gitignore` is a safety net). `git/.gitconfig` has no `user.*` or `credential.*`. Credentials stay with Git's credential helper, the keychain, and `gh auth`. Brewfile trust is recorded by `brew bundle` in `~/.homebrew/trust.json`. This repository contains no secrets or tokens.

## Maintaining the repository

- Edit the `Brewfile` by hand. Do not run `brew bundle dump`.
- Bump `python/version` when the workstation Python pin changes.
- Add a macOS default as one `ensure_default` call in `scripts/macos/defaults.sh`, plus a README bullet and its inverse `defaults write`.
- Run `make lint test` before pushing. CI runs the same on pull requests and `main`.
- Record architecture decisions in `knowledge/decisions/`.
- Compatibility floor: system Bash 3.2 and GNU Make 3.81.
- After a merge, `make git_pull` refreshes local `main`.

## Design boundaries

No Nix, Ansible, MDM, or other configuration-management stack. No dotfiles framework. No cross-platform support. The clone never replaces `~/.bashrc` or rewrites `~/.gitconfig`. Tests never mutate the machine. Secrets, tokens, and project IDE configuration (`.cursor/`, `.vscode/`) stay out of the repository.

## License

Apache License 2.0; see `LICENSE`.
