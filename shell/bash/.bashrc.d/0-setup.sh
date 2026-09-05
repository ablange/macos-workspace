# shell/bash/.bashrc.d/0-setup.sh - Bash aliases and global settings

alias ll='ls -a -A -l'

# pipx installs apps into ~/.local/bin (replaces `pipx ensurepath`).
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
