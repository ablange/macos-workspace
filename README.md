# macos-workspace
Build system written in Bash designed to streamline development on macOS.


## Features
- __Bash shell manager__
  - Programmatically manage dotfiles (e.g., `.bashrc`) with version control.
  - Build shell from scratch anytime with [Makefile](https://www.gnu.org/software/make/manual/make.html) commands.
  - Customize Bash terminal prompt with [PS1](https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html).
- __Data Product Development Templates__
  - Rapidly prototype data products by initializing project templates with [copier](https://copier.readthedocs.io/en/stable/).
  - All templates run in isolated Docker containers to ensure modularity.
  - Templates provide specialized components designed 
  to simplify software-related aspects data engineering.
    - `Python`: Python 3.11 project with Pyenv virtual environment ontop of isolated Docker container.  
    - __`Duckdb`__: Coming soon!   
    - __`Jupyter`__: Coming soon!
    - __`Airflow`__: Coming soon!


## Prerequisites

> ⚠️ Requires macOS Sequoia 15.0> or later.

1. Install Docker Desktop:
https://docs.docker.com/desktop/install/mac-install/


2. Install core macOS developer utilities:
```commandline
xcode-select --install
```

3. Change your default macOS shell from zsh to bash:
```commandline
chsh -s /bin/bash
```

4. Install Homebrew package manager:
```commandline
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

5. Install GitHub CLI and authenticate.
```commandline
brew install gh
gh auth
```


## Installation
Clone ``macos-workspace`` into a new ``repos/`` directory.
```commandline
(mkdir -p ~/repos/
gh repo clone ablange/macos-workspace ~/repos/macos-workspace)
```

Build your workspace. 
```commandline
cd ~/repos/macos-workspace/
make setup
```


Restart shell for changes to take effect.
```commandline
exec bash
```


## Usage
To get started using your workspace, build the projects you need inside ``repos/``
and use them interdependently as needed.

Here is a list of templates available to build inside ``macos-workspace``.
* python
* duckdb
* jupyter
* airflow


### Python
Let's walk through building a Python 3.11.9 project called ``foo``.
```commandline

make python project=foo version=3.11.9
```

After you complete questionnaire, a project directory will be created in ``repos/``.

Setup your Python project development environment.
```commandline
cd ~/repos/foo
make setup
```
Now when you cd into ``foo/`` your development environment is automatically activated.

Finally, push your new project to GitHub and start working on a new branch. 

Change into your new project directory and push to GitHub.
```commandline
git init
git push origin main
git checkout -B feature
```

### DuckDB
TODO

### Jupyter
TODO

### Airflow
TODO
