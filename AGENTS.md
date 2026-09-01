# Agent instructions

- Inspect the repository before editing. Follow the project roadmap milestone-by-milestone and stop at the active milestone's definition of done.
- Never replace or append to user files (`~/.bashrc`, `~/.gitconfig`). Prefer `source` / `[include]` indirection.
- No destructive shell: no `rm -rf` on user paths, no `defaults delete`, no `killall` beyond Finder/Dock, no `sudo`, no reboot or logout.
- No secrets or tokens ever, including in examples.
- Architecture is Homebrew + Brewfile + Bash + pyenv + Make. Do not introduce Nix, Ansible, or dotfiles frameworks.
- Executable scripts under `scripts/` use `#!/usr/bin/env bash` and `set -euo pipefail`, and are idempotent.
- Sourced shell configuration under `shell/` must never set strict-mode flags or require a shebang; it runs inside the user's interactive shell.
- All Bash must run on system Bash 3.2 (no `globstar`, `mapfile`, associative arrays, or `${var,,}`) and GNU Make 3.81.
- `make lint test` must pass before completion.
- Tests must never mutate the machine. Only `make doctor` inspects the machine, and it only reports.
- Do not inherit architecture or configuration from historical workspace projects unless explicitly asked to inspect a specific pattern.
- Do not add `.cursor/`, `.vscode/`, or project-specific IDE configuration.
- Record decisions in `knowledge/decisions/`.
- Never hard-code Homebrew prefixes such as `/opt/homebrew`; use `brew --prefix` or `brew shellenv`.
