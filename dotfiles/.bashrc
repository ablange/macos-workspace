# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pyenv-virtualenv
function cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./.env ]] ; then
        source ./.env/bin/activate
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}

# git
source ~/.git-completion.bash
source ~/.git-prompt.sh

# bash prompt
PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)"); PS1_CMD2=$(pyenv version-name)'; PS1='\[\e[34m\][\u\[\e[34m\]@\[\e[34m\]\h\[\e[34m\]]\[\e[0m\] \[\e[96m\](\[\e[96m\]\w\[\e[96m\])\[\e[91m\]${PS1_CMD1}\[\e[0m\] \[\e[92m\](${PS1_CMD2})\n\[\e[0m\]\$ '

# bash aliases
source ~/.bash_aliases
