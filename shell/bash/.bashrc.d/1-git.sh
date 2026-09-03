# shell/bash/.bashrc.d/1-git.sh - Git aliases and completion

alias gs='git status'
alias gaddall='git add -A'
alias gcom='git commit -m'
alias gd='git diff'
alias gbs='git branch -a'
alias gsl='git log --graph --oneline --decorate HEAD'

_git_completion=""
if command -v xcode-select >/dev/null 2>&1; then
    _clt="$(xcode-select -p 2>/dev/null)" || _clt=""
    if [ -n "$_clt" ] && [ -f "$_clt/usr/share/git-core/git-completion.bash" ]; then
        _git_completion="$_clt/usr/share/git-core/git-completion.bash"
    fi
fi
if [ -z "$_git_completion" ] && [ -f "$HOME/.git-completion.bash" ]; then
    _git_completion="$HOME/.git-completion.bash"
fi
if [ -n "$_git_completion" ]; then
    # shellcheck source=/dev/null
    source "$_git_completion"
fi
unset _git_completion _clt
