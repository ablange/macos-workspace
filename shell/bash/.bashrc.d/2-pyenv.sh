# shell/bash/.bashrc.d/2-pyenv.sh - Pyenv configuration

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
[[ -d $PYENV_ROOT/bin ]] && case ":$PATH:" in
    *":$PYENV_ROOT/bin:"*) ;;
    *) export PATH="$PYENV_ROOT/bin:$PATH" ;;
esac
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
