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

The clone never replaces `~/.bashrc` or rewrites `~/.gitconfig`. Shell integration is manual: the user adds a single `source` line. `make git` adds one safe, idempotent `include.path` for portable Git config. Machine-specific values stay in local files that this repository does not track.

## Homebrew

M01 is implemented. The root `Brewfile` is the intentional software contract: a hand-curated list of top-level formulae and casks, never generated with `brew bundle dump`. pyenv owns Python interpreters. Docker Desktop owns the container runtime, the `docker` CLI, and Compose.

- `make prerequisites` verifies Xcode Command Line Tools and installs Homebrew when it is missing.
- `make brew` installs missing declared packages with `brew bundle install --no-upgrade`. It does not proactively upgrade existing Brewfile packages. Installing a missing package may still upgrade a dependency that package requires. It never runs `bundle cleanup`, `autoremove`, `--force`, or `--adopt`.

Existing GUI applications are left unmanaged and untouched. Homebrew installs the cask only when the corresponding application is absent from `/Applications`. This avoids brittle automatic cask adoption while still allowing a fresh Mac to install the full application baseline. `make brew` never adopts, overwrites, or reinstalls an existing GUI app.

Third-party trust is formula-scoped (`trusted: true` on `databricks/tap/databricks` and `astronomer/tap/astro`) and recorded in `~/.homebrew/trust.json` by `brew bundle`. Application and cloud authentication stay manual.

The standalone Homebrew `docker` and `podman` formulae are not part of the intended contract. `astro` is declared from the Astronomer tap with `--without-podman` so Docker Desktop stays the sole container runtime. The Homebrew-core `astro` formula is omitted because it forces Podman. Apps without a cask stay manual.

## One-time migration — review before running

These commands **change the Mac**. They are **not** automated and **must not** be run as part of repository validation. Review them, then run them explicitly if you want this machine to match the M01 contract.

Before uninstalling, inspect what Homebrew thinks depends on the packages and what autoremove would drop:

```bash
brew uses --installed docker
brew uses --installed podman
brew autoremove --dry-run
```

Then migrate. `HOMEBREW_NO_AUTOREMOVE=1` keeps unused formula dependencies in place so they can be reviewed instead of removed automatically. `brew uninstall astro` removes the Homebrew-core formula (which pulls Podman); `make brew` then installs `astronomer/tap/astro` with `--without-podman`.

```bash
HOMEBREW_NO_AUTOREMOVE=1 brew uninstall docker docker-completion
HOMEBREW_NO_AUTOREMOVE=1 brew uninstall astro podman
make brew
```

After the uninstalls, inspect leftover dependencies again and decide whether any should actually go:

```bash
brew autoremove --dry-run
```

Optional review (out of scope for `make brew`; do not automate):

- `coreutils` (present only as a dependency today)
- `tcl-tk` and `zlib` leaves
- unrelated Nix profile entries on `PATH`

## Bash

M02 is implemented. `shell/bash/` is the existing mini-data-stack-hedge-fund shell setup moved into this repository with ownership, idempotency, and fresh-Mac helper-discovery edits: local overrides load from `~/.bashrc.local`, the hard-coded Homebrew prefix example is gone, re-sourcing does not duplicate `$PYENV_ROOT/bin` on `PATH` or `set_prompt` in `PROMPT_COMMAND`, and Git completion/prompt helpers come from Xcode Command Line Tools when available.

Add one line to the existing `~/.bashrc`. `make shell` prints the line for this clone and never edits the file:

```bash
source "$HOME/<clone-location>/macos-workspace/shell/bash/.bashrc"
```

The path depends on where the repository is cloned. `~/.bashrc` is not replaced. `~/.bash_profile` keeps `brew shellenv` and Homebrew bash-completion; macOS Terminal opens login shells, so `~/.bash_profile` should also `source ~/.bashrc`. Use `~/.bashrc.local` for machine-specific shell config (see `shell/bash/.bashrc.local.example`).

Git completion and the branch prompt load from the helper files that ship with Xcode Command Line Tools (`usr/share/git-core/git-completion.bash` and `git-prompt.sh`), discovered with `xcode-select -p`. If those files are missing, the fragments fall back to `~/.git-completion.bash` and `~/.git-prompt.sh` when present. A Mac without CLT helpers and without those home files still gets aliases and the Python prompt segment, but not branch display or Git completion.

Verify after a new login shell:

```bash
bash -lic 'alias ll; type __git_ps1; echo "$PROMPT_COMMAND"'
```

## Git

Portable Git settings live in `git/.gitconfig`: aliases (`s`, `d`, `bs`, `addall`, `com`), `core.editor = nano`, `init.defaultBranch = main`, and an include of `~/.gitconfig.local`. Identity and other machine-specific values live in `~/.gitconfig.local` (copy `git/.gitconfig.local.example`). Credentials stay with Git's credential helper, `gh auth`, and the keychain.

The include chain is `~/.gitconfig` → `<clone>/git/.gitconfig` → `~/.gitconfig.local`. Later values win, so repository settings override earlier keys in `~/.gitconfig`, and `~/.gitconfig.local` overrides the repository. If you change an alias or editor in `~/.gitconfig` before the include, the repository value still wins; put overrides in `~/.gitconfig.local`.

`make git` adds one `include.path` after checking whether the exact clone path is already present. It never appends blindly and never removes existing keys. If another `*/macos-workspace/git/.gitconfig` include points at a previous clone, it prints both paths and exits 1 without writing.

Global ignore patterns live in `git/ignore` (OS and editor files only). `make git` symlinks Git's default `~/.config/git/ignore` to that file only when the path is absent. It does not write `core.excludesFile`. If `core.excludesFile` is already set in global or system config, or if anything already exists at the XDG ignore path, `make git` reports that and leaves it alone.

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
- `brew` — `brew bundle` from the Brewfile (install missing packages; no proactive upgrade, cleanup, or GUI-app adoption)
- `git_pull` — checkout `main`, pull `origin main`, then prune remote-tracking refs (`git fetch -p`)
- `shell` — print the Bash `source` line; exit 0 when it is merely missing; never edit `~/.bashrc`
- `git` — one idempotent `include.path` plus the global-ignore symlink

Planned:

- `python` — pyenv default version and `pipx ensurepath`
- `macos` — curated, reversible defaults
- `bootstrap` — run the above in order, then `doctor`
- `doctor` — report-only drift checks
- `status` — terse summary

## Fresh-Mac workflow

1. Clone this repository.
2. Confirm `make help`, `make lint`, and `make test` succeed.
3. Run `make prerequisites`, then `make brew`.
4. Run `make shell`, add the printed line to `~/.bashrc`, then run `make git`.
5. Complete documented manual steps (auth, apps without a cask, GUI preferences).

## One-time migration — shell and Git

These steps **change the Mac**. They are **not** automated and **must not** be run as part of repository validation.

1. In `~/.bashrc`, replace a `mini-data-stack-hedge-fund/shell/bash/.bashrc` source line with the macos-workspace line printed by `make shell`. Keep `export PATH="$HOME/.local/bin:$PATH"` in `~/.bashrc` if it is already there; no fragment provides it.
2. In `~/.bash_profile`, keep `brew shellenv`, the Homebrew bash-completion line, and `source ~/.bashrc`. The `pyenv init` and `pyenv virtualenv-init` lines duplicate `2-pyenv.sh`; removing them is optional and eliminates duplicate shim paths on `PATH`.
3. `~/.git-completion.bash` and `~/.git-prompt.sh` are optional. After Command Line Tools are installed, the fragments load the CLT copies. Keep the home files only as a fallback, or remove them once a new login shell defines `__git_ps1`.
4. If an in-repo `mini-data-stack-hedge-fund/shell/bash/.bashrc.local` exists, copy its contents to `~/.bashrc.local` by hand.
5. After `make git`, the repository supplies `alias.*` and `core.editor`. You may delete the accumulated `[alias]` block and a stray `[core] editor` from `~/.gitconfig` (for example `git config --global --unset-all alias.bs`), then verify with `git config --get-all alias.bs` (expect one value). Optionally move `[user]` into `~/.gitconfig.local`. Leave credential sections where they are.
6. If this clone is ever moved, `make git` reports the stale include and a dangling `~/.config/git/ignore`. Remove them by hand (`git config --global --unset include.path '<old path>'`, then `rm ~/.config/git/ignore` after `readlink` confirms it is the dangling link), update the `~/.bashrc` source line, and rerun `make shell` and `make git`. This is never automated.

Pre-existing and out of scope: Nix profile `PATH` entries; `~/.pyenv/version` and interpreters (M03).

## Roadmap

M00 (Repository Foundation), M01 (Homebrew Workstation Baseline), and M02 (Shell and Git Environment) are what this tree implements. M03 (Python) is next. The authoritative roadmap lives outside this repository; knowledge files record durable architecture and decisions only.
