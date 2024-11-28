# Homebrew
eval “$(/opt/homebrew/bin/brew shellenv)”

# Pyenv
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
