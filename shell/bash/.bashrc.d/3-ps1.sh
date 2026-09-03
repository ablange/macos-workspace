# shell/bash/.bashrc.d/3-ps1.sh - PS1 prompt with Git branch and Python version

_git_prompt=""
if command -v xcode-select >/dev/null 2>&1; then
    _clt="$(xcode-select -p 2>/dev/null)" || _clt=""
    if [ -n "$_clt" ] && [ -f "$_clt/usr/share/git-core/git-prompt.sh" ]; then
        _git_prompt="$_clt/usr/share/git-core/git-prompt.sh"
    fi
fi
if [ -z "$_git_prompt" ] && [ -f "$HOME/.git-prompt.sh" ]; then
    _git_prompt="$HOME/.git-prompt.sh"
fi
if [ -n "$_git_prompt" ]; then
    # shellcheck source=/dev/null
    source "$_git_prompt"
fi
unset _git_prompt _clt

set_prompt() {
    if command -v __git_ps1 >/dev/null 2>&1; then
        PS1_CMD1=$(__git_ps1 " (%s)")
    else
        PS1_CMD1=""
    fi

    if command -v pyenv >/dev/null 2>&1; then
        PS1_CMD2=$(pyenv version-name 2>/dev/null || echo "system")
    else
        PS1_CMD2="system"
    fi

    PS1='\[\e[34m\][\u\[\e[34m\]@\[\e[34m\]\h\[\e[34m\]]\[\e[0m\] \[\e[96m\](\[\e[96m\]\w\[\e[96m\])\[\e[91m\]'
    PS1+="${PS1_CMD1}"
    PS1+='\[\e[0m\] \[\e[92m\]('
    PS1+="${PS1_CMD2}"
    PS1+=')\n\[\e[0m\]\$ '
}

case "$PROMPT_COMMAND" in
    *set_prompt*) ;;
    '')
        PROMPT_COMMAND="set_prompt"
        ;;
    *';')
        PROMPT_COMMAND="${PROMPT_COMMAND}set_prompt"
        ;;
    *)
        PROMPT_COMMAND="${PROMPT_COMMAND};set_prompt"
        ;;
esac

set_prompt
