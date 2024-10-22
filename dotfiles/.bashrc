# Custom PS1 Terminal Prompt
PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)"); PS1_CMD2=$(pyenv version-name)'; PS1='\[\e[34m\][\u\[\e[34m\]@\[\e[34m\]\h\[\e[34m\]]\[\e[0m\] \[\e[96m\](\[\e[96m\]\w\[\e[96m\])\[\e[91m\]${PS1_CMD1}\[\e[0m\] \[\e[92m\](${PS1_CMD2})\n\[\e[0m\]\$ '
source ~/.bash_aliases

# Git
source ~/.git-prompt.sh
source ~/.git-completion.bash
export GIT_EDITOR=nano

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Pyenv-virtualenv
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
