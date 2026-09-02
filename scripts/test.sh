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

required_files="README.md LICENSE Makefile Brewfile AGENTS.md .gitignore knowledge/index.md knowledge/architecture/repository.md knowledge/decisions/0001-workstation-bootstrap-architecture.md knowledge/decisions/0002-homebrew-package-contract.md scripts/lint.sh scripts/test.sh scripts/prerequisites.sh scripts/brew.sh"
for file in $required_files; do
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
if grep -E "${opt_home}${brew_suffix}|${usr_home}${brew_suffix}" Makefile Brewfile scripts/*.sh >/dev/null; then
  fail "hard-coded Homebrew prefix in Makefile, Brewfile, or scripts"
else
  pass "no hard-coded Homebrew prefix in Makefile, Brewfile, or scripts"
fi

if grep -E 'bundle cleanup|autoremove|--force' scripts/brew.sh >/dev/null; then
  fail "scripts/brew.sh must not use bundle cleanup, autoremove, or --force"
else
  pass "scripts/brew.sh has no bundle cleanup, autoremove, or --force"
fi

if grep -q 'brew bundle' Makefile; then
  fail "Makefile must not invoke Homebrew Bundle; delegate to a script"
else
  pass "Makefile does not invoke Homebrew Bundle"
fi

# Match a Homebrew CLI invocation. Quoted DSL needles such as 'brew "
# do not match because a quote precedes the token.
if grep -E '(^|[[:space:]])brew[[:space:]]' scripts/test.sh >/dev/null; then
  fail "scripts/test.sh must not invoke Homebrew"
else
  pass "scripts/test.sh does not invoke Homebrew"
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

if [ "$failures" -ne 0 ]; then
  echo "test: $failures check(s) failed"
  exit 1
fi

echo "test: ok"
