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

required_files="README.md LICENSE Makefile Brewfile AGENTS.md .gitignore knowledge/index.md knowledge/architecture/repository.md knowledge/decisions/0001-workstation-bootstrap-architecture.md scripts/lint.sh scripts/test.sh"
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

if grep -qEv '^[[:space:]]*(#|$)' Brewfile; then
  fail "Brewfile is not comment-only"
else
  pass "Brewfile is comment-only"
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
