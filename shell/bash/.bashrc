# shell/bash/.bashrc - imports all shell fragments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/.bashrc.d" ]; then
    for file in "$SCRIPT_DIR/.bashrc.d"/*.sh; do
        if [ -r "$file" ]; then
            # shellcheck source=/dev/null
            source "$file"
        fi
    done
fi

if [ -r "$HOME/.bashrc.local" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc.local"
fi
