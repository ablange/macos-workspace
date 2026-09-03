#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT
export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"
REPO_ROOT="$(pwd)"

required_files=(
  README.md
  LICENSE
  Makefile
  Brewfile
  AGENTS.md
  .gitignore
  knowledge/index.md
  knowledge/architecture/repository.md
  knowledge/decisions/0001-workstation-bootstrap-architecture.md
  knowledge/decisions/0002-homebrew-package-contract.md
  scripts/lint.sh
  scripts/test.sh
  scripts/prerequisites.sh
  scripts/brew.sh
  scripts/git_pull.sh
  scripts/shell.sh
  scripts/git.sh
  scripts/python.sh
  python/version
  shell/bash/.bashrc
  shell/bash/.bashrc.local.example
  shell/bash/.bashrc.d/0-setup.sh
  shell/bash/.bashrc.d/1-git.sh
  shell/bash/.bashrc.d/2-pyenv.sh
  shell/bash/.bashrc.d/3-ps1.sh
  git/.gitconfig
  git/.gitconfig.local.example
  git/ignore
  knowledge/decisions/0003-shell-and-git-indirection.md
)
for file in "${required_files[@]}"; do
  if [ -e "$file" ]; then
    pass "exists: $file"
  else
    fail "missing: $file"
  fi
done

if grep -q 'Apache License' LICENSE && grep -q 'Version 2.0' LICENSE; then
  pass "LICENSE is Apache 2.0"
else
  fail "LICENSE is not Apache 2.0"
fi

if grep -qE '^brew "' Brewfile && grep -qE '^cask "' Brewfile; then
  pass "Brewfile declares formula and cask entries"
else
  fail "Brewfile must declare at least one formula and one cask"
fi

if grep -Ev '^[[:space:]]*(#|$)' Brewfile | grep -Ev '^(tap|brew|cask) "' >/dev/null; then
  fail "Brewfile has a line that is not a tap, brew, or cask declaration"
else
  pass "Brewfile declaration lines are valid DSL"
fi

if grep -qE '^brew "python' Brewfile; then
  fail "Brewfile must not declare a Homebrew Python interpreter"
else
  pass "Brewfile does not declare a Homebrew Python interpreter"
fi

if grep -qE '^cask "docker-desktop"' Brewfile; then
  pass "Brewfile declares docker-desktop cask"
else
  fail "Brewfile missing docker-desktop cask"
fi

if grep -E '^cask "' Brewfile | grep -v 'unless File.exist?("/Applications/' >/dev/null; then
  fail "every Brewfile cask must be gated on File.exist? of an /Applications bundle"
else
  pass "every Brewfile cask is gated on an /Applications bundle"
fi

while IFS='|' read -r cask_name app_path; do
  [ -n "$cask_name" ] || continue
  expected="cask \"${cask_name}\" unless File.exist?(\"${app_path}\")"
  if grep -Fqx "$expected" Brewfile; then
    pass "Brewfile gates ${cask_name} on ${app_path}"
  else
    fail "Brewfile must declare: ${expected}"
  fi
done <<'EOF'
docker-desktop|/Applications/Docker.app
cursor|/Applications/Cursor.app
dbeaver-community|/Applications/DBeaver.app
iterm2|/Applications/iTerm.app
chatgpt|/Applications/ChatGPT.app
google-chrome|/Applications/Google Chrome.app
microsoft-teams|/Applications/Microsoft Teams.app
rectangle|/Applications/Rectangle.app
zoom|/Applications/zoom.us.app
EOF

if grep -qE '^brew "(docker|docker-compose|podman)"' Brewfile; then
  fail "Brewfile must not declare standalone docker, docker-compose, or podman formulae"
else
  pass "Brewfile omits standalone docker, docker-compose, and podman formulae"
fi

if grep -qE '^brew "astro"' Brewfile; then
  fail "Brewfile must not declare the Homebrew-core astro formula"
else
  pass "Brewfile omits the Homebrew-core astro formula"
fi

if grep -qE '^brew "astronomer/tap/astro".*without-podman' Brewfile; then
  pass "Brewfile declares astronomer/tap/astro without Podman"
else
  fail "Brewfile must declare astronomer/tap/astro with without-podman"
fi

# Forbidden prefix strings are split so this file is not a self-match.
opt_home="/opt/home"
usr_home="/usr/local/Home"
brew_suffix="brew"
if grep -RE "${opt_home}${brew_suffix}|${usr_home}${brew_suffix}" Makefile Brewfile scripts shell git >/dev/null; then
  fail "hard-coded Homebrew prefix in Makefile, Brewfile, scripts, shell, or git"
else
  pass "no hard-coded Homebrew prefix in Makefile, Brewfile, scripts, shell, or git"
fi

if grep -E 'bundle cleanup|autoremove|--force|--adopt' scripts/brew.sh >/dev/null; then
  fail "scripts/brew.sh must not use bundle cleanup, autoremove, --force, or --adopt"
else
  pass "scripts/brew.sh has no bundle cleanup, autoremove, --force, or --adopt"
fi

if grep -Ei 'safe adoption|safely adopt' README.md knowledge/decisions/0002-homebrew-package-contract.md >/dev/null; then
  fail "docs must not claim Homebrew Bundle safely adopts existing applications"
else
  pass "docs do not claim Homebrew Bundle safely adopts existing applications"
fi

if grep -q 'left unmanaged and untouched' README.md &&
  grep -q 'left unmanaged and untouched' knowledge/decisions/0002-homebrew-package-contract.md; then
  pass "README and ADR 0002 state existing GUI apps are left unmanaged"
else
  fail "README and ADR 0002 must state existing GUI apps are left unmanaged and untouched"
fi

if grep -q 'brew bundle' Makefile; then
  fail "Makefile must not invoke Homebrew Bundle; delegate to a script"
else
  pass "Makefile does not invoke Homebrew Bundle"
fi

if grep -E '(^|[[:space:]])git[[:space:]]' Makefile >/dev/null; then
  fail "Makefile must not invoke git; delegate to a script"
else
  pass "Makefile does not invoke git"
fi

git_pull_commands="$(grep -E '^git ' scripts/git_pull.sh || true)"
expected_git_pull_commands="$(printf '%s\n' 'git checkout main' 'git pull origin main' 'git fetch -p')"
if [ "$git_pull_commands" = "$expected_git_pull_commands" ]; then
  pass "git_pull.sh checks out main, pulls origin, and prunes remotes"
else
  fail "git_pull.sh must run git checkout main, git pull origin main, then git fetch -p"
fi

# Match a Homebrew CLI invocation. Quoted DSL needles such as 'brew "
# do not match because a quote precedes the token.
if grep -E '(^|[[:space:]])brew[[:space:]]' scripts/test.sh >/dev/null; then
  fail "scripts/test.sh must not invoke Homebrew"
else
  pass "scripts/test.sh does not invoke Homebrew"
fi

# Command tokens are split so this file is not a self-match.
mgr_py="pyenv"
mgr_px="pipx"
if grep -E "(^|[[:space:]])(${mgr_py}|${mgr_px})[[:space:]]" scripts/test.sh >/dev/null; then
  fail "scripts/test.sh must not invoke the workstation ${mgr_py}/${mgr_px} binaries"
else
  pass "scripts/test.sh does not invoke the workstation ${mgr_py}/${mgr_px} binaries"
fi

while IFS= read -r file; do
  [ -n "$file" ] || continue
  if [ -x "$file" ]; then
    pass "executable: $file"
  else
    fail "not executable: $file"
  fi
  if /bin/bash -n "$file"; then
    pass "parses: $file"
  else
    fail "does not parse: $file"
  fi
done <<EOF
$(find scripts -type f -name '*.sh' -print)
EOF

if make help >/dev/null; then
  pass "make help exits 0"
else
  fail "make help exited non-zero"
fi

while IFS= read -r target; do
  [ -n "$target" ] || continue
  if make -n "$target" >/dev/null; then
    pass "advertised target exists: $target"
  else
    fail "advertised target missing: $target"
  fi
done <<EOF
$(make help | awk '{print $1}')
EOF

if git ls-files | grep -E '\.cursor/|\.vscode/|\.code-workspace$' >/dev/null; then
  fail "tracked .cursor/, .vscode/, or *.code-workspace path"
else
  pass "no tracked IDE paths"
fi

if [ -d knowledge ]; then
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    first="$(head -n 1 "$file")"
    if [ "$first" = "---" ]; then
      pass "frontmatter: $file"
    else
      fail "missing YAML frontmatter: $file"
    fi
  done <<EOF
$(find knowledge -type f -name '*.md' -print)
EOF
fi

tree_checksum() {
  local dir="$1"
  (
    cd "$dir" || exit 1
    find . -print | LC_ALL=C sort | while IFS= read -r path; do
      if [ -L "$path" ]; then
        printf 'symlink %s -> %s\n' "$path" "$(readlink "$path")"
      elif [ -f "$path" ]; then
        cksum "$path"
      else
        printf 'path %s\n' "$path"
      fi
    done
  )
}

with_git_env() {
  local work="$1"
  shift
  HOME="$work" \
    XDG_CONFIG_HOME="$work/.config" \
    GIT_CONFIG_GLOBAL="$work/.gitconfig" \
    GIT_CONFIG_SYSTEM="$work/system-gitconfig" \
    "$@"
}

if git ls-files --cached --others --exclude-standard | grep -Fxq 'shell/bash/.bashrc.local.example'; then
  pass "shell/bash/.bashrc.local.example is tracked or committable"
else
  fail "shell/bash/.bashrc.local.example must be tracked"
fi

if git ls-files --cached --others --exclude-standard | grep -Fxq 'git/.gitconfig.local.example'; then
  pass "git/.gitconfig.local.example is tracked or committable"
else
  fail "git/.gitconfig.local.example must be tracked"
fi

if git check-ignore -q shell/bash/.bashrc.local; then
  pass "git check-ignore matches shell/bash/.bashrc.local"
else
  fail "shell/bash/.bashrc.local must be gitignored"
fi

if git check-ignore -q git/.gitconfig.local; then
  pass "git check-ignore matches git/.gitconfig.local"
else
  fail "git/.gitconfig.local must be gitignored"
fi

if grep -RE 'set[[:space:]]+(-euo[[:space:]]+pipefail|-o[[:space:]]+pipefail|-e\b|-u\b)' shell >/dev/null; then
  fail "shell/ must not enable strict mode"
else
  pass "shell/ does not enable strict mode"
fi

if grep -R '/Users/' shell git scripts/shell.sh scripts/git.sh scripts/python.sh >/dev/null; then
  fail "personal /Users/ path in shell/, git/, scripts/shell.sh, scripts/git.sh, or scripts/python.sh"
else
  pass "no /Users/ path in shell/, git/, scripts/shell.sh, scripts/git.sh, or scripts/python.sh"
fi

if grep -RE '/Library/Developer/CommandLineTools|/Applications/Xcode\.app' shell scripts/shell.sh scripts/git.sh >/dev/null; then
  fail "hard-coded Xcode or CLT path in shell/ or integration scripts"
else
  pass "no hard-coded Xcode or CLT path in shell/ or integration scripts"
fi

# Literal include path as written in git/.gitconfig, not an expansion.
# shellcheck disable=SC2088
local_include='~/.gitconfig.local'
if grep -Fq "$local_include" git/.gitconfig; then
  pass "git/.gitconfig includes ~/.gitconfig.local"
else
  fail "git/.gitconfig must include ~/.gitconfig.local"
fi

if [ -s git/ignore ]; then
  pass "git/ignore is non-empty"
else
  fail "git/ignore must be non-empty"
fi

if git config --file git/.gitconfig --list >/dev/null; then
  pass "git/.gitconfig parses"
else
  fail "git/.gitconfig failed to parse"
fi

if git config --file git/.gitconfig --get-regexp '^user\.' >/dev/null 2>&1; then
  fail "git/.gitconfig must not set user.*"
else
  pass "git/.gitconfig has no user.*"
fi

if git config --file git/.gitconfig --get-regexp '^credential\.' >/dev/null 2>&1; then
  fail "git/.gitconfig must not set credential.*"
else
  pass "git/.gitconfig has no credential.*"
fi

if make -n shell | grep -Eq '^[[:space:]]*\./scripts/shell\.sh$'; then
  pass "Makefile shell recipe is ./scripts/shell.sh"
else
  fail "Makefile shell recipe must be a single ./scripts/shell.sh line"
fi

if make -n git | grep -Eq '^[[:space:]]*\./scripts/git\.sh$'; then
  pass "Makefile git recipe is ./scripts/git.sh"
else
  fail "Makefile git recipe must be a single ./scripts/git.sh line"
fi

if make -n python | grep -Eq '^[[:space:]]*\./scripts/python\.sh$'; then
  pass "Makefile python recipe is ./scripts/python.sh"
else
  fail "Makefile python recipe must be a single ./scripts/python.sh line"
fi

pyenv_tok="pyenv"
if grep -E "^[[:space:]]+${pyenv_tok}[[:space:]]" Makefile >/dev/null; then
  fail "Makefile must not invoke ${pyenv_tok}; delegate to a script"
else
  pass "Makefile does not invoke ${pyenv_tok}"
fi

if [ "$(wc -l < python/version | tr -d ' ')" = "1" ] && grep -qxE '^[0-9]+\.[0-9]+\.[0-9]+$' python/version; then
  pass "python/version is a single X.Y.Z line"
else
  fail "python/version must be one X.Y.Z line"
fi

forbid_un="uninstall"
forbid_px_path="pipx"" ensurepath"
forbid_pip="pip"" install"
forbid_px_inst="pipx"" install"
if grep -E "${forbid_un}|${forbid_px_path}|${forbid_pip}|${forbid_px_inst}" scripts/python.sh >/dev/null; then
  fail "scripts/python.sh must not uninstall or install packages"
else
  pass "scripts/python.sh does not uninstall or install packages"
fi

if grep -E -- '--unset|--replace-all|ln -sf|(^|[[:space:]])rm([[:space:]]|$)' scripts/git.sh >/dev/null; then
  fail "scripts/git.sh must not use --unset, --replace-all, ln -sf, or rm"
else
  pass "scripts/git.sh has no --unset, --replace-all, ln -sf, or rm"
fi

run_sandbox_shell() {
  local work="$1"
  local script="$2"
  local path="${3:-/usr/bin:/bin:/usr/sbin:/sbin}"
  env -i HOME="$work" PATH="$path" TERM=dumb /bin/bash --noprofile --norc -c "$script"
}

work="$(mktemp -d "$TMP_HOME/load-basic.XXXXXX")"
if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && alias ll gs >/dev/null && type set_prompt >/dev/null && case \"\$PROMPT_COMMAND\" in *set_prompt*) ;; *) exit 1;; esac"; then
  pass "temp-HOME shell load defines aliases, set_prompt, and PROMPT_COMMAND"
else
  fail "temp-HOME shell load failed"
fi

work="$(mktemp -d "$TMP_HOME/load-local.XXXXXX")"
cat > "$work/.bashrc.local" <<'EOF'
BASHRC_LOCAL_MARKER=1
alias ll='echo local-ll'
EOF
if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && [ \"\$BASHRC_LOCAL_MARKER\" = 1 ] && alias ll | grep -q local-ll"; then
  pass "temp-HOME ~/.bashrc.local is sourced last and can override ll"
else
  fail "temp-HOME ~/.bashrc.local last-wins failed"
fi

work="$(mktemp -d "$TMP_HOME/load-idempotent.XXXXXX")"
mkdir -p "$work/.pyenv/bin"
if run_sandbox_shell "$work" "
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  n=\$(printf '%s' \"\$PROMPT_COMMAND\" | grep -o set_prompt | wc -l | tr -d ' ')
  [ \"\$n\" = 1 ] || exit 1
  n=0
  oldifs=\$IFS
  IFS=:
  for entry in \$PATH; do
    if [ \"\$entry\" = \"\$HOME/.pyenv/bin\" ]; then
      n=\$((n + 1))
    fi
  done
  IFS=\$oldifs
  [ \"\$n\" = 1 ] || exit 1
  n=0
  oldifs=\$IFS
  IFS=:
  for entry in \$PATH; do
    if [ \"\$entry\" = \"\$HOME/.local/bin\" ]; then
      n=\$((n + 1))
    fi
  done
  IFS=\$oldifs
  [ \"\$n\" = 1 ]
"; then
  pass "re-sourcing does not duplicate set_prompt, PYENV_ROOT/bin, or .local/bin"
else
  fail "re-sourcing duplicated set_prompt, PYENV_ROOT/bin, or .local/bin"
fi

work="$(mktemp -d "$TMP_HOME/load-prompt.XXXXXX")"
err="$work/set_prompt.err"
if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && set_prompt" 2>"$err" && [ ! -s "$err" ]; then
  pass "set_prompt is silent without a version manager or git-prompt"
else
  fail "set_prompt wrote stderr or failed without a version manager or git-prompt"
fi

work="$(mktemp -d "$TMP_HOME/load-prompt-command.XXXXXX")"
if run_sandbox_shell "$work" "
  PROMPT_COMMAND='history -a'
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  n=\$(printf '%s' \"\$PROMPT_COMMAND\" | grep -o set_prompt | wc -l | tr -d ' ')
  [ \"\$n\" = 1 ] || exit 1
  [ \"\$PROMPT_COMMAND\" = 'history -a;set_prompt' ] || exit 1
"; then
  pass "PROMPT_COMMAND history -a stays valid and registers set_prompt once"
else
  fail "PROMPT_COMMAND history -a registration failed"
fi

work="$(mktemp -d "$TMP_HOME/load-prompt-trailing.XXXXXX")"
if run_sandbox_shell "$work" "
  PROMPT_COMMAND='history -a; '
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  [ \"\$PROMPT_COMMAND\" = 'history -a;set_prompt' ] || exit 1
"; then
  pass "PROMPT_COMMAND history -a; with trailing space stays valid and registers once"
else
  fail "PROMPT_COMMAND trailing-space registration failed"
fi

work="$(mktemp -d "$TMP_HOME/load-prompt-reset.XXXXXX")"
if run_sandbox_shell "$work" "
  PROMPT_COMMAND='reset_prompt'
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  source \"$REPO_ROOT/shell/bash/.bashrc\"
  [ \"\$PROMPT_COMMAND\" = 'reset_prompt;set_prompt' ] || exit 1
"; then
  pass "PROMPT_COMMAND reset_prompt is not treated as set_prompt"
else
  fail "PROMPT_COMMAND reset_prompt substring blocked set_prompt"
fi

work="$(mktemp -d "$TMP_HOME/load-clt-helpers.XXXXXX")"
clt_root="$(xcode-select -p 2>/dev/null || true)"
if [ -n "$clt_root" ] && [ -f "$clt_root/usr/share/git-core/git-prompt.sh" ]; then
  if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && type __git_ps1 >/dev/null && alias gs >/dev/null"; then
    pass "CLT git helpers load without ~/.git-prompt.sh"
  else
    fail "CLT git helpers did not load __git_ps1"
  fi
else
  pass "CLT git helpers unavailable; skipped load check"
fi

work="$(mktemp -d "$TMP_HOME/load-helper-fallback.XXXXXX")"
mkdir -p "$work/bin"
printf '%s\n' '#!/bin/sh' 'exit 1' > "$work/bin/xcode-select"
chmod +x "$work/bin/xcode-select"
printf '%s\n' '__git_ps1() { printf %s "(home)"; }' > "$work/.git-prompt.sh"
if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && type __git_ps1 >/dev/null" "$work/bin:/usr/bin:/bin:/usr/sbin:/sbin"; then
  pass "home git-prompt.sh is used when CLT helpers are unavailable"
else
  fail "home git-prompt.sh fallback failed"
fi

work="$(mktemp -d "$TMP_HOME/load-helper-absent.XXXXXX")"
err="$work/helpers.err"
mkdir -p "$work/bin"
printf '%s\n' '#!/bin/sh' 'exit 1' > "$work/bin/xcode-select"
chmod +x "$work/bin/xcode-select"
if run_sandbox_shell "$work" "source \"$REPO_ROOT/shell/bash/.bashrc\" && alias ll gs >/dev/null && set_prompt && ! type __git_ps1 >/dev/null 2>&1" "$work/bin:/usr/bin:/bin:/usr/sbin:/sbin" 2>"$err" && [ ! -s "$err" ]; then
  pass "missing CLT and home git helpers degrade silently"
else
  fail "missing git helpers were not silent or broke aliases"
fi

work="$(mktemp -d "$TMP_HOME/git-fresh.XXXXXX")"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -eq 0 ]; then
  pass "git.sh fresh run 1 exits 0"
else
  fail "git.sh fresh run 1 exited $status"
fi
sum1="$(tree_checksum "$work")"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -eq 0 ]; then
  pass "git.sh fresh run 2 exits 0"
else
  fail "git.sh fresh run 2 exited $status"
fi
sum2="$(tree_checksum "$work")"
if [ "$sum1" = "$sum2" ]; then
  pass "git.sh second run writes nothing"
else
  fail "git.sh second run changed the temp HOME tree"
fi

include_count="$(with_git_env "$work" git config --global --get-all include.path 2>/dev/null | wc -l | tr -d ' ')"
if [ "$include_count" = 1 ]; then
  pass "git.sh fresh include.path has exactly one value"
else
  fail "git.sh fresh include.path count is $include_count"
fi

if [ "$(readlink "$work/.config/git/ignore")" = "$REPO_ROOT/git/ignore" ]; then
  pass "git.sh links XDG git/ignore to the repository file"
else
  fail "git.sh did not link XDG git/ignore to $REPO_ROOT/git/ignore"
fi

if [ "$(with_git_env "$work" git config --global --includes --get alias.bs)" = "branch" ]; then
  pass "git.sh alias.bs resolves to branch via --includes"
else
  fail "git.sh alias.bs did not resolve to branch"
fi

if with_git_env "$work" git config --global --includes --get core.excludesfile >/dev/null 2>&1; then
  fail "git.sh must not write core.excludesfile"
else
  pass "git.sh leaves core.excludesfile unset"
fi

ignore_repo="$(mktemp -d "$TMP_HOME/ignore-repo.XXXXXX")"
empty_template="$(mktemp -d "$TMP_HOME/git-template.XXXXXX")"
status=0
(
  cd "$ignore_repo" || exit 1
  with_git_env "$work" git init --template="$empty_template" >/dev/null
  touch .DS_Store
  with_git_env "$work" git check-ignore -q .DS_Store
) || status=$?
if [ "$status" -eq 0 ]; then
  pass "git check-ignore matches .DS_Store via XDG ignore"
else
  fail "git check-ignore did not match .DS_Store"
fi

work="$(mktemp -d "$TMP_HOME/git-protect.XXXXXX")"
mkdir -p "$work/.config/git"
printf '%s\n' '[user]' '	name = Example' > "$work/.gitconfig"
printf '%s\n' 'keep-this-marker' > "$work/.config/git/ignore"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -eq 0 ]; then
  pass "git.sh protect-existing exits 0"
else
  fail "git.sh protect-existing exited $status"
fi
if [ "$(with_git_env "$work" git config --global --includes --get user.name)" = "Example" ]; then
  pass "git.sh preserves existing user.name"
else
  fail "git.sh changed existing user.name"
fi
if [ -L "$work/.config/git/ignore" ]; then
  fail "git.sh replaced an existing ignore file with a symlink"
elif [ -f "$work/.config/git/ignore" ] && grep -Fxq 'keep-this-marker' "$work/.config/git/ignore"; then
  pass "git.sh left the existing ignore file in place"
else
  fail "git.sh mutated the existing ignore file"
fi
if printf '%s\n' "$out" | grep -Fq "$work/.config/git/ignore"; then
  pass "git.sh reports the existing ignore path"
else
  fail "git.sh did not mention the existing ignore path"
fi

work="$(mktemp -d "$TMP_HOME/git-excludes-global.XXXXXX")"
printf '%s\n' '[core]' '	excludesfile = ~/other' > "$work/.gitconfig"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -eq 0 ]; then
  pass "git.sh global-excludesFile exits 0"
else
  fail "git.sh global-excludesFile exited $status"
fi
# Compare to the literal core.excludesfile value written above.
# shellcheck disable=SC2088
expected_excludes='~/other'
if [ "$(with_git_env "$work" git config --global --get core.excludesfile)" = "$expected_excludes" ]; then
  pass "git.sh leaves global core.excludesFile unchanged"
else
  fail "git.sh changed global core.excludesFile"
fi
if printf '%s\n' "$out" | grep -q 'core.excludesFile is set'; then
  pass "git.sh reports a set global core.excludesFile"
else
  fail "git.sh did not report a set global core.excludesFile"
fi
if [ ! -e "$work/.config/git/ignore" ] && [ ! -L "$work/.config/git/ignore" ]; then
  pass "git.sh skips the ignore symlink when global core.excludesFile is set"
else
  fail "git.sh created an ignore path while core.excludesFile is set"
fi

work="$(mktemp -d "$TMP_HOME/git-excludes-system.XXXXXX")"
printf '%s\n' '[core]' '	excludesfile = ~/other' > "$work/system-gitconfig"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -eq 0 ]; then
  pass "git.sh system-excludesFile exits 0"
else
  fail "git.sh system-excludesFile exited $status"
fi
# Compare to the literal core.excludesfile value written above.
# shellcheck disable=SC2088
expected_excludes='~/other'
if [ "$(with_git_env "$work" git config --system --includes --get core.excludesfile)" = "$expected_excludes" ]; then
  pass "git.sh leaves system core.excludesFile unchanged"
else
  fail "git.sh changed system core.excludesFile"
fi
if printf '%s\n' "$out" | grep -q 'core.excludesFile is set'; then
  pass "git.sh reports a set system core.excludesFile"
else
  fail "git.sh did not report a set system core.excludesFile"
fi
if [ ! -e "$work/.config/git/ignore" ] && [ ! -L "$work/.config/git/ignore" ]; then
  pass "git.sh skips the ignore symlink when system core.excludesFile is set"
else
  fail "git.sh created an ignore path while system core.excludesFile is set"
fi

work="$(mktemp -d "$TMP_HOME/git-stale.XXXXXX")"
printf '%s\n' '[include]' '	path = /old/path/macos-workspace/git/.gitconfig' > "$work/.gitconfig"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
if [ "$status" -ne 0 ]; then
  pass "git.sh stale-include exits non-zero"
else
  fail "git.sh stale-include exited 0"
fi
if printf '%s\n' "$out" | grep -Fq '/old/path/macos-workspace/git/.gitconfig' &&
  printf '%s\n' "$out" | grep -Fq "$REPO_ROOT/git/.gitconfig"; then
  pass "git.sh stale-include reports the old and new paths"
else
  fail "git.sh stale-include did not report both include paths"
fi
include_count="$(with_git_env "$work" git config --global --get-all include.path 2>/dev/null | wc -l | tr -d ' ')"
if [ "$include_count" = 1 ]; then
  pass "git.sh stale-include does not add or remove include.path"
else
  fail "git.sh stale-include changed include.path count to $include_count"
fi

work="$(mktemp -d "$TMP_HOME/git-stale-and-current.XXXXXX")"
printf '%s\n' '[user]' '	name = Example' '[include]' \
  "	path = $REPO_ROOT/git/.gitconfig" \
  '	path = /old/path/macos-workspace/git/.gitconfig' > "$work/.gitconfig"
before="$(tree_checksum "$work")"
status=0
out="$(with_git_env "$work" ./scripts/git.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -ne 0 ]; then
  pass "git.sh current-plus-stale exits non-zero"
else
  fail "git.sh current-plus-stale exited 0"
fi
if printf '%s\n' "$out" | grep -Fq '/old/path/macos-workspace/git/.gitconfig' &&
  printf '%s\n' "$out" | grep -Fq "$REPO_ROOT/git/.gitconfig"; then
  pass "git.sh current-plus-stale reports both include paths"
else
  fail "git.sh current-plus-stale did not report both include paths"
fi
if [ "$before" = "$after" ]; then
  pass "git.sh current-plus-stale writes nothing"
else
  fail "git.sh current-plus-stale changed the temp HOME tree"
fi
include_count="$(with_git_env "$work" git config --global --get-all include.path 2>/dev/null | wc -l | tr -d ' ')"
if [ "$include_count" = 2 ]; then
  pass "git.sh current-plus-stale leaves both include.path values"
else
  fail "git.sh current-plus-stale changed include.path count to $include_count"
fi
if [ "$(with_git_env "$work" git config --global --get user.name)" = "Example" ]; then
  pass "git.sh current-plus-stale preserves existing user.name"
else
  fail "git.sh current-plus-stale changed existing user.name"
fi
if [ ! -e "$work/.config/git/ignore" ] && [ ! -L "$work/.config/git/ignore" ]; then
  pass "git.sh current-plus-stale does not create an ignore symlink"
else
  fail "git.sh current-plus-stale created an ignore path"
fi

work="$(mktemp -d "$TMP_HOME/shell-missing.XXXXXX")"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'source "' && printf '%s\n' "$out" | grep -q 'shell/bash/.bashrc'; then
  pass "shell.sh prints the source line and exits 0 when ~/.bashrc is missing"
else
  fail "shell.sh missing-line report failed"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh missing-line run does not write under HOME"
else
  fail "shell.sh missing-line run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-present.XXXXXX")"
printf '%s\n' "source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' 'source ~/.bashrc' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'sources'; then
  pass "shell.sh reports when ~/.bashrc already sources the clone"
else
  fail "shell.sh present-line report failed"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh present-line run does not write under HOME"
else
  fail "shell.sh present-line run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-warning.XXXXXX")"
printf '%s\n' "source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' '# login profile without bashrc' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'warning'; then
  pass "shell.sh warns when ~/.bash_profile does not source ~/.bashrc"
else
  fail "shell.sh bash_profile warning failed"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh warning run does not write under HOME"
else
  fail "shell.sh warning run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-commented-bashrc.XXXXXX")"
printf '%s\n' "# source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' 'source ~/.bashrc' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'add this line' &&
  ! printf '%s\n' "$out" | grep -q "sources $REPO_ROOT/shell/bash/.bashrc"; then
  pass "shell.sh treats a commented ~/.bashrc source line as inactive"
else
  fail "shell.sh treated a commented ~/.bashrc source line as active"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh commented-bashrc run does not write under HOME"
else
  fail "shell.sh commented-bashrc run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-commented-profile.XXXXXX")"
printf '%s\n' "source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' '# source ~/.bashrc' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'warning'; then
  pass "shell.sh treats a commented ~/.bash_profile source line as inactive"
else
  fail "shell.sh treated a commented ~/.bash_profile source line as active"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh commented-profile run does not write under HOME"
else
  fail "shell.sh commented-profile run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-profile-local-only.XXXXXX")"
printf '%s\n' "source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' 'source ~/.bashrc.local' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -q 'warning'; then
  pass "shell.sh does not treat source ~/.bashrc.local as sourcing ~/.bashrc"
else
  fail "shell.sh treated source ~/.bashrc.local as sourcing ~/.bashrc"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh bashrc.local-only profile run does not write under HOME"
else
  fail "shell.sh bashrc.local-only profile run changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/shell-dot-profile.XXXXXX")"
printf '%s\n' "source \"$REPO_ROOT/shell/bash/.bashrc\"" > "$work/.bashrc"
printf '%s\n' '. ~/.bashrc' > "$work/.bash_profile"
before="$(tree_checksum "$work")"
status=0
out="$(HOME="$work" ./scripts/shell.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] && ! printf '%s\n' "$out" | grep -q 'warning'; then
  pass "shell.sh accepts . ~/.bashrc in ~/.bash_profile"
else
  fail "shell.sh did not accept . ~/.bashrc"
fi
if [ "$before" = "$after" ]; then
  pass "shell.sh dot-profile run does not write under HOME"
else
  fail "shell.sh dot-profile run changed the temp HOME tree"
fi

install_fake_pyenv() {
  local work="$1"
  mkdir -p "$work/bin" "$work/.pyenv"
  cat > "$work/bin/pyenv" <<'EOF'
#!/bin/sh
root="${PYENV_ROOT:-$HOME/.pyenv}"
cmd="$1"
shift
case "$cmd" in
  root)
    printf '%s\n' "$root"
    ;;
  prefix)
    printf '%s\n' "$root/versions/$1"
    ;;
  global)
    if [ -n "${1:-}" ]; then
      printf '%s\n' "$1" > "$root/version"
    elif [ -f "$root/version" ]; then
      cat "$root/version"
    else
      printf '%s\n' "system"
    fi
    ;;
  install)
    version=""
    for arg in "$@"; do
      case "$arg" in
        --skip-existing) ;;
        *) version="$arg" ;;
      esac
    done
    mkdir -p "$root/versions/$version/bin"
    printf '%s\n' "#!/bin/sh" "echo Python $version" > "$root/versions/$version/bin/python"
    chmod +x "$root/versions/$version/bin/python"
    ;;
esac
EOF
  chmod +x "$work/bin/pyenv"
}

install_fake_pipx() {
  local work="$1"
  mkdir -p "$work/bin"
  printf '%s\n' '#!/bin/sh' 'exit 0' > "$work/bin/pipx"
  chmod +x "$work/bin/pipx"
}

run_python_sh() {
  local work="$1"
  env -i HOME="$work" PATH="$work/bin:/usr/bin:/bin" PYENV_ROOT="$work/.pyenv" ./scripts/python.sh
}

pin="$(tr -d '[:space:]' < python/version)"

work="$(mktemp -d "$TMP_HOME/python-missing-mgr.XXXXXX")"
before="$(tree_checksum "$work")"
status=0
out="$(env -i HOME="$work" PATH="/usr/bin:/bin" PYENV_ROOT="$work/.pyenv" ./scripts/python.sh 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -ne 0 ] && printf '%s\n' "$out" | grep -q 'make brew'; then
  pass "python.sh missing manager exits 1 and names make brew"
else
  fail "python.sh missing manager did not fail as expected"
fi
if [ "$before" = "$after" ]; then
  pass "python.sh missing manager does not write under HOME"
else
  fail "python.sh missing manager changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/python-missing-px.XXXXXX")"
install_fake_pyenv "$work"
before="$(tree_checksum "$work")"
status=0
out="$(run_python_sh "$work" 2>&1)" || status=$?
after="$(tree_checksum "$work")"
if [ "$status" -ne 0 ] && printf '%s\n' "$out" | grep -q "${mgr_px}" && printf '%s\n' "$out" | grep -q 'make brew'; then
  pass "python.sh missing ${mgr_px} exits 1 and names make brew"
else
  fail "python.sh missing ${mgr_px} did not fail as expected"
fi
if [ "$before" = "$after" ]; then
  pass "python.sh missing ${mgr_px} does not write under HOME"
else
  fail "python.sh missing ${mgr_px} changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/python-fresh.XXXXXX")"
install_fake_pyenv "$work"
install_fake_pipx "$work"
status=0
out="$(run_python_sh "$work" 2>&1)" || status=$?
if [ "$status" -eq 0 ] &&
  printf '%s\n' "$out" | grep -q 'Installing' &&
  printf '%s\n' "$out" | grep -q 'Setting global' &&
  printf '%s\n' "$out" | grep -Fq "Python $pin"; then
  pass "python.sh fresh install exits 0 and reports install plus global"
else
  fail "python.sh fresh install failed"
fi
if [ "$(cat "$work/.pyenv/version")" = "$pin" ]; then
  pass "python.sh fresh install writes the pinned global version"
else
  fail "python.sh fresh install did not set the pinned global version"
fi
if [ ! -e "$work/.bashrc" ] && [ ! -e "$work/.bash_profile" ]; then
  pass "python.sh fresh install does not create .bashrc or .bash_profile"
else
  fail "python.sh created .bashrc or .bash_profile"
fi

sum1="$(tree_checksum "$work")"
status=0
out="$(run_python_sh "$work" 2>&1)" || status=$?
sum2="$(tree_checksum "$work")"
if [ "$status" -eq 0 ] &&
  printf '%s\n' "$out" | grep -q 'already installed' &&
  printf '%s\n' "$out" | grep -q 'already the global'; then
  pass "python.sh rerun reports already installed and already the global"
else
  fail "python.sh rerun messages failed"
fi
if [ "$sum1" = "$sum2" ]; then
  pass "python.sh rerun writes nothing"
else
  fail "python.sh rerun changed the temp HOME tree"
fi

work="$(mktemp -d "$TMP_HOME/python-switch-global.XXXXXX")"
install_fake_pyenv "$work"
install_fake_pipx "$work"
mkdir -p "$work/.pyenv/versions/$pin/bin" "$work/.pyenv/versions/3.12.8"
printf '%s\n' "#!/bin/sh" "echo Python $pin" > "$work/.pyenv/versions/$pin/bin/python"
chmod +x "$work/.pyenv/versions/$pin/bin/python"
printf '%s\n' '3.12.8' > "$work/.pyenv/version"
status=0
out="$(run_python_sh "$work" 2>&1)" || status=$?
if [ "$status" -eq 0 ] &&
  printf '%s\n' "$out" | grep -q 'already installed' &&
  printf '%s\n' "$out" | grep -q 'Setting global'; then
  pass "python.sh sets global when the pin is already installed"
else
  fail "python.sh did not set global for a preinstalled pin"
fi
if [ -d "$work/.pyenv/versions/3.12.8" ]; then
  pass "python.sh leaves other installed versions in place"
else
  fail "python.sh removed another installed version"
fi
if [ "$(cat "$work/.pyenv/version")" = "$pin" ]; then
  pass "python.sh switch-global writes the pinned version"
else
  fail "python.sh switch-global did not write the pinned version"
fi
if [ ! -e "$work/.bashrc" ] && [ ! -e "$work/.bash_profile" ]; then
  pass "python.sh switch-global does not create .bashrc or .bash_profile"
else
  fail "python.sh switch-global created .bashrc or .bash_profile"
fi

if [ "$failures" -ne 0 ]; then
  echo "test: $failures check(s) failed"
  exit 1
fi

echo "test: ok"
