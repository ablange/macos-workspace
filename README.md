# macos-workspace

A macOS developer workstation, defined in Git: Homebrew packages and applications, Bash configuration, portable Git settings, a pinned Python version, and a few specific macOS preferences (e.g., Finder, Dock).

Rebuilding a developer Mac by hand takes hours and is easy to get wrong. The decisions that make the machine yours are spread across package lists, shell files, Git settings, and system preferences, and most of them are never written down.

`macos-workspace` keeps those decisions in one repository. `make bootstrap` installs the declared software and applies the shell, Git, Python, and macOS configuration in a fixed order. The repository is the source of truth for the workstation: when the machine changes, the repository changes with it. Each change can be reviewed, tested, and committed, and the next Mac starts from the current definition instead of an old snapshot.

This repository describes one person's workstation. It is meant to be forked.

> [!NOTE]
> **Make it your own.** Fork this repository, then edit the `Brewfile`, shell fragments, Python version, Git defaults, and macOS preferences to match your Mac. Commit changes as your workstation changes, so the repository stays the source of truth.

> [!WARNING]
> **Intended for a clean or new Mac.** On an existing workstation, `make bootstrap` installs packages and a Python version, changes Finder and Dock preferences, adds a Git include, and, once sourced, changes shell behavior. Read the `Brewfile`, `Makefile`, `shell/`, `git/`, and `scripts/macos/defaults.sh` first, and inspect the order with `make -n bootstrap`. Where practical, try your fork on a new macOS user or a fresh virtual machine.

## Features

- **One command, fixed order.** `make bootstrap` runs `prerequisites → brew → shell → git → python → macos` and stops at the first failure. Each step is its own Make target and is safe to rerun.
- **Declarative software.** A hand-curated `Brewfile` lists the intended packages and applications. `make brew` installs only what is missing.
- **Integration by indirection.** Bash loads through one `source` line and Git through one `include.path`. `~/.bashrc` and `~/.gitconfig` are never replaced or rewritten.
- **Local values stay local.** Identity and host-specific settings live in untracked `~/.bashrc.local` and `~/.gitconfig.local`, which load last and win.
- **Pinned Python.** pyenv installs the version in `python/version` and makes it the global interpreter, independent of Homebrew's Python formulae.
- **Small, reversible macOS changes.** Seven Finder and Dock preferences, each read before it is written, each with a documented inverse.
- **Tested without touching the machine.** `make lint test` checks the repository and its scripts in a temporary home directory, locally and in CI.

## Prerequisites

Start from a Mac with the Xcode Command Line Tools:

```bash
xcode-select --install
```

Use Bash as your login shell

```bash
chsh -s /bin/bash
```

## Installation

### 1. Clone the repository

```bash
mkdir -p "$HOME/repos"
git clone https://github.com/ablange/macos-workspace.git "$HOME/repos/macos-workspace"
cd "$HOME/repos/macos-workspace"
```

### 2. Run the bootstrap

```bash
make bootstrap
```

> [!WARNING]
> If `prerequisites` installs Homebrew, the bootstrap stops there because `brew` is not yet on `PATH`. Follow the Next steps printed by the Homebrew installer, open a new terminal window, and run `make bootstrap` again.

### 3. Load the Bash configuration

Append the `source` line to `~/.bashrc`:

```bash
cat <<'EOF' >> ~/.bashrc

# macos-workspace
source "$HOME/repos/macos-workspace/shell/bash/.bashrc"
EOF
```

Terminal opens login shells, which read `~/.bash_profile` rather than `~/.bashrc`. If `~/.bash_profile` does not already source `~/.bashrc`, add that too:

```bash
grep -qxF 'source ~/.bashrc' ~/.bash_profile 2>/dev/null || printf '%s\n' 'source ~/.bashrc' >> ~/.bash_profile
```

Then open a new terminal window. `make shell` is read-only and reports whether both files are wired correctly.

> [!NOTE]
> From here on, every new terminal starts with the repository's prompt, aliases, Git completion, and `PATH`.

### 4. Finish the manual steps

Some setup stays manual because it involves authentication, first-run dialogs, or Privacy & Security permissions: your Git identity in `~/.gitconfig.local`, an optional `~/.bashrc.local`, `gh auth login`, Docker Desktop's first run, optional AWS, Databricks, and Astronomer logins, and the Accessibility permission for Rectangle. Follow [docs/manual-setup.md](docs/manual-setup.md).

## Make targets

| Target | Purpose |
| --- | --- |
| `help` | Show available targets |
| `lint` | Run static checks |
| `test` | Run repository invariant tests |
| `prerequisites` | Verify Xcode Command Line Tools and install Homebrew if missing |
| `brew` | Install missing `Brewfile` packages; no proactive upgrade or cleanup |
| `shell` | Print the Bash `source` line to add; never edits `~/.bashrc` |
| `git` | Add one idempotent `include.path` and link the global ignore file |
| `python` | Install the pinned pyenv Python if missing and set `pyenv global` |
| `macos` | Apply curated, reversible Finder and Dock defaults; restart only on change |
| `bootstrap` | Run the automated setup targets in dependency order |
| `git_pull` | Refresh local `main` after a PR merge |

`git_pull` is a maintainer convenience: it checks out `main`, pulls `origin main`, then prunes stale remote-tracking references with `git fetch -p`. It is not part of `bootstrap`.

## Verifying the repository

From the repository root:

```bash
make lint test
```

`lint` checks that scripts are executable, use `#!/usr/bin/env bash` and `set -euo pipefail`, parse under `/bin/bash`, and pass ShellCheck when it is installed, and that sourced shell files never set strict-mode flags. `test` checks required files, `Brewfile` rules, bootstrap composition, and the behavior of the shell, Git, Python, and macOS scripts against a temporary home directory with stand-in tools; it never calls Homebrew, pyenv, or `defaults` for real.

Neither target changes your machine. They prove the repository is internally consistent and its scripts behave as specified, not that a particular Mac is fully configured. The only end-to-end check is a real bootstrap on a clean macOS user or virtual machine.


## Maintaining the repository

- Edit the `Brewfile` by hand; never generate it with `brew bundle dump`. Keep every cask gated on its `/Applications` bundle. Do not declare Homebrew Python interpreters or the standalone `docker`, `docker-compose`, or `podman` formulae; pyenv and Docker Desktop own those.
- Add a macOS preference as one `ensure_default` call in `scripts/macos/defaults.sh` plus a row, with its inverse, in the macOS table under *What the bootstrap changes*. Restart only Finder or Dock.
- Scripts under `scripts/` use `#!/usr/bin/env bash` and `set -euo pipefail` and must be idempotent. Sourced files under `shell/` never set strict-mode flags.
- Everything must run on system Bash 3.2 and GNU Make 3.81, so avoid newer features such as `mapfile`, associative arrays, `.ONESHELL`, and `$(file ...)`. Never hard-code a Homebrew prefix; use `brew --prefix` or `brew shellenv`.
- Never replace or append to `~/.bashrc` or `~/.gitconfig` from code. No `rm -rf` on user paths, `defaults delete`, `sudo`, or `killall` beyond Finder and Dock. Tests must never mutate the machine.
- Run `make lint test` before pushing. CI runs the same checks on `macos-latest` for pull requests and pushes to `main`. Record architecture decisions in `knowledge/decisions/`.

Prefer small changes. If a setting is brittle, security-sensitive, rarely changed, or easier to do by hand than to maintain in code, document it instead of automating it.


## Methodology

> Automate high-value, stable configuration. Document brittle or infrequent configuration.

Each managed area uses the tool that already owns it: Homebrew and a `Brewfile` for software, Bash fragments for the shell, Git's own `include` for Git, pyenv for Python, and `defaults` for macOS preferences. Make is the human interface. Each setup target runs one script, each script is idempotent, and each can be read in a few minutes. That keeps the workstation definition small enough for a person, or a coding agent, to understand and change safely.

Configuration that is personal, security-sensitive, unstable, or rarely performed lives in [docs/manual-setup.md](docs/manual-setup.md) instead of code. Out of scope: configuration-management stacks such as Nix, Ansible, or MDM; dotfiles frameworks; cross-platform support; project IDE configuration; Git identity; cloud logins; and secrets of any kind.

### Machine-local configuration

Two untracked files hold everything personal:

| File | Holds | Loaded by |
| --- | --- | --- |
| `~/.gitconfig.local` | `user.name`, `user.email`, other host-specific Git settings | `git/.gitconfig`, included last |
| `~/.bashrc.local` | Local shell settings and overrides | `shell/bash/.bashrc`, sourced last |

`git/.gitconfig.local.example` and `shell/bash/.bashrc.local.example` show the expected shape. `.gitignore` also excludes copies of the real files inside the repository as a safety net.

`git/.gitconfig` contains no `user.*` or `credential.*` keys; the tests enforce this. Credentials stay with Git's credential helper, the macOS Keychain, `gh auth`, and each tool's own login. Homebrew records the two tap trusts in `~/.homebrew/trust.json`, outside the repository. The repository holds no passwords, tokens, or keys.

### What the bootstrap changes

**Homebrew.** `make brew` runs `brew bundle install --no-upgrade` and never runs `bundle cleanup`, `autoremove`, `--force`, or `--adopt`. Installing a missing package can still upgrade a dependency it requires. Each cask is declared only when its application is absent from `/Applications`; applications already there are left unmanaged and untouched. Two formulae come from third-party taps, Astronomer and Databricks, and each is marked `trusted: true` individually.

**Bash.** `shell/bash/.bashrc` loads the fragments in `shell/bash/.bashrc.d/` in order, then `~/.bashrc.local`. They add `~/.local/bin` (pipx apps) to `PATH`, define `ll` and a few Git aliases, load Git completion and the branch prompt from the Command Line Tools when present, initialize pyenv, and set a prompt showing user, host, directory, Git branch, and active Python version.

**Git.** `make git` adds one `include.path` for `git/.gitconfig` to your global Git configuration and links `~/.config/git/ignore` to `git/ignore` only when that path is absent and no `core.excludesFile` is set. `git/.gitconfig` sets `init.defaultBranch = main`, `core.editor = nano`, and a few aliases, then includes `~/.gitconfig.local` last. If an include from another clone location already exists, `make git` reports it and stops.

**Python.** `make python` uses pyenv to install the version in `python/version` if it is missing and sets it as `pyenv global`. It does not remove other versions, install packages, or edit shell files.

**macOS.** `make macos` reads each preference first and writes only when the value differs. Finder or Dock restarts at most once per run, and only when a key in that group changed.

| Domain and key | Value | Effect | Inverse |
| --- | --- | --- | --- |
| `NSGlobalDomain AppleShowAllExtensions` | `-bool true` | Show all file extensions | `-bool false` |
| `com.apple.finder FXPreferredViewStyle` | `-string Nlsv` | List view for new Finder windows | another style, such as `-string icnv` |
| `com.apple.finder ShowHardDrivesOnDesktop` | `-bool true` | Internal volumes on the Desktop | `-bool false` |
| `com.apple.finder ShowExternalHardDrivesOnDesktop` | `-bool true` | External volumes on the Desktop | `-bool false` |
| `com.apple.finder ShowRemovableMediaOnDesktop` | `-bool true` | Removable media on the Desktop | `-bool false` |
| `com.apple.finder ShowMountedServersOnDesktop` | `-bool true` | Mounted servers on the Desktop | `-bool false` |
| `com.apple.dock autohide` | `-bool true` | Auto-hide the Dock | `-bool false` |

Revert a key with `defaults write` and its inverse, then restart Finder or Dock, or change it in System Settings. If a restart fails after a write, retry it with `MACOS_RESTART=finder make macos`, `MACOS_RESTART=dock make macos`, or `MACOS_RESTART=finder,dock make macos`; the variable only restarts and never writes. Input, appearance, and security or privacy settings are not automated.


### Updating your workstation

The repository is meant to change as the machine changes. Edit the source of truth for the area, then apply it:

| Change | Edit | Apply |
| --- | --- | --- |
| Package or application | `Brewfile` | `make brew` |
| Python version | `python/version` | `make python` |
| Shell behavior | `shell/bash/.bashrc.d/` | open a new shell |
| Portable Git settings | `git/.gitconfig`, `git/ignore` | nothing; Git reads the files in place |
| macOS preference | `scripts/macos/defaults.sh` | `make macos` |
| Manual step | `docs/manual-setup.md` | follow the document |

The workflow is: change the machine or the desired configuration → update the repository → run `make lint test` → review the diff → commit.

Coding agents can help inspect the machine, update the repository, run the tests, and review diffs. [AGENTS.md](AGENTS.md) gives them the same rules maintainers follow. For a maintenance pass, give a coding agent [docs/prompts/maintain-workspace.md](docs/prompts/maintain-workspace.md).


## Risks

- **Existing workstation state can conflict with the managed configuration.** Homebrew packages, `PATH` entries, Git settings, and shell customizations may already exist in another form. Prefer a clean Mac. Otherwise read the files named in the warning above, inspect the order with `make -n bootstrap`, and run targets one at a time.

- **`make brew` installs software, including from third-party taps.** It installs every missing `Brewfile` entry, and installing a missing package can upgrade dependencies it requires. Remove entries you do not want before running it. It never proactively upgrades declared packages, never removes packages, and leaves applications already in `/Applications` alone.

- **Shell and Git behavior changes without your files being replaced.** Sourcing the repository changes `PATH`, aliases, `PROMPT_COMMAND`, and the prompt. The Git include contributes aliases, `core.editor`, and `init.defaultBranch`; because Git keeps the last value it reads, the include can override the same keys set earlier in `~/.gitconfig`. Put overrides in `~/.bashrc.local` and `~/.gitconfig.local`, which load last. Removing one `source` line or one `include.path` disconnects the repository.

- **`make macos` changes preferences for the current user and restarts Finder or Dock.** Only the seven keys listed above are touched. Each is read first, written only when it differs, and has a documented inverse.


## Future improvements

- An end-to-end test on a clean macOS user profile or virtual machine. Today the only end-to-end check is a manual bootstrap.
- Recorded macOS-version compatibility as new releases are tested.


## Uninstallation

There is no one-command uninstall, on purpose: software installed from the `Brewfile` may now be used by other projects, so removal is riskier than installation. Reverse only the pieces you no longer want:

1. Remove the `macos-workspace` `source` line from `~/.bashrc`.
2. Remove the `include.path` entry for `git/.gitconfig` from your global Git configuration.
3. If `~/.config/git/ignore` is a symlink to the repository's `git/ignore`, remove or replace it.
4. Revert any macOS preference you no longer want with its inverse, then restart Finder or Dock.
5. Uninstall only the Homebrew packages and applications you know you no longer need. When you do, set `HOMEBREW_NO_AUTOREMOVE=1` and inspect leftover dependencies with `brew autoremove --dry-run` before removing anything.
6. Leave the Python versions under `~/.pyenv` unless nothing else depends on them. `~/.bashrc.local` and `~/.gitconfig.local` are yours; keep them.
7. Delete the clone last, after steps 1 to 3, because the shell and Git integration point at it.

For a machine-specific plan, give a coding agent this prompt:

```text
Plan a safe uninstall of my macos-workspace configuration. Inspect the
repository and how it is integrated with this machine. Produce a
step-by-step plan that removes only the macos-workspace shell and Git
integration, lists the exact macOS preferences to revert with their
inverses, and separates Brewfile software that is safe to remove from
software that may be used elsewhere. Do not remove credentials, user
data, or unrelated configuration. Show me the plan and its risks before
changing anything.
```


## License

Apache License 2.0. See [LICENSE](LICENSE).