# macos-workspace
# Getting Started
## Prerequisites
Here is a list of prerequisites
we need to install on macOS
before we can begin building our workspace.
##### 1: Core macOS developer utilities
```commandline
xcode-select --install
```


##### 2: Change your default macOS shell to bash
```commandline
chsh -s /bin/bash
```


##### 3: Homebrew package manager
```commandline
/bin/bash -c "$(curl -fsSL \ https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


##### 4: Install GitHub CLI
```commandline
brew install gh
gh auth
```


## Installation
Clone into ``repos/`` and run ``make setup`` command.
```commandline
(mkdir -p ~/repos/
cd ~/repos/
gh repo clone ablange/macos-workspace
cd ~/macos-workspace/
make setup)
```

Restart shell for changes to take effect.
```commandline
exec bash
```


# Templates
List templates available to build.
```commandline
cd ~/repos/macos-workspace/
make
```

## Python
Build a Python 3.11.9 project
```commandline
make python project=foo version=3.11.9
```
Now whenever you ``cd`` into ``~/repos/foo/``,
your virtual environment is automatically 
changed accordingly.
