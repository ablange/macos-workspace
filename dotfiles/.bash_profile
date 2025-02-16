# Homebrew
eval “$(/opt/homebrew/bin/brew shellenv)”

# Pyenv
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# Bash command auto-complete
[[ -r "$HOMEBREW_REPOSITORY/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_REPOSITORY/etc/profile.d/bash_completion.sh"
