# 0: OS dependencies
eval “$(/opt/homebrew/bin/brew shellenv)”

# 3: Python
# 3a: pyenv
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 3b: pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
