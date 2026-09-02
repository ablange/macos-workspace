#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

failures=0

require_executable_script() {
  local file="$1"
  local first

  if [ ! -x "$file" ]; then
    echo "lint: not executable: $file"
    failures=$((failures + 1))
  fi

  first="$(head -n 1 "$file")"
  if [ "$first" != "#!/usr/bin/env bash" ]; then
    echo "lint: missing #!/usr/bin/env bash: $file"
    failures=$((failures + 1))
  fi

  if ! grep -q 'set -euo pipefail' "$file"; then
    echo "lint: missing set -euo pipefail: $file"
    failures=$((failures + 1))
  fi

  if ! /bin/bash -n "$file"; then
    echo "lint: /bin/bash -n failed: $file"
    failures=$((failures + 1))
  fi
}

parse_sourced_fragment() {
  local file="$1"

  if ! /bin/bash -n "$file"; then
    echo "lint: /bin/bash -n failed: $file"
    failures=$((failures + 1))
  fi
}

shellcheck_available=0
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck_available=1
else
  echo "lint: shellcheck not found; skipping (declared in Brewfile; run 'make brew')"
fi

run_shellcheck() {
  local file="$1"

  if [ "$shellcheck_available" -eq 0 ]; then
    return 0
  fi

  if ! shellcheck -x "$file"; then
    echo "lint: shellcheck failed: $file"
    failures=$((failures + 1))
  fi
}

while IFS= read -r file; do
  [ -n "$file" ] || continue
  require_executable_script "$file"
  run_shellcheck "$file"
done <<EOF
$(find scripts -type f -name '*.sh' -print)
EOF

if [ -f shell/bash/.bashrc ]; then
  parse_sourced_fragment shell/bash/.bashrc
fi

if [ -d shell/bash/.bashrc.d ]; then
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    parse_sourced_fragment "$file"
  done <<EOF
$(find shell/bash/.bashrc.d -type f -name '*.sh' -print)
EOF
fi

if [ "$failures" -ne 0 ]; then
  echo "lint: $failures check(s) failed"
  exit 1
fi

echo "lint: ok"
