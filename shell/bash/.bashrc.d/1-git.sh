# shell/bash/.bashrc.d/1-git.sh - Git aliases and completion

alias gs='git status'
alias gaddall='git add -A'
alias gcom='git commit -m'
alias gd='git diff'
alias gbs='git branch -a'
alias gsl='git log --graph --oneline --decorate HEAD'

if [ -f ~/.git-completion.bash ]; then
    # shellcheck source=/dev/null
    source ~/.git-completion.bash
fi
