# macos-workspace
Build system designed to streamline data projects on macOS.


## Features
- __Bash Shell Manager__
  - Programmatically manage your local shell with [Makefile](https://www.gnu.org/software/make/manual/make.html) commands.
  - Store your dotfiles (e.g., `.bashrc`) in version control.
  - Reproduce 100% of your terminal setup any macOS machine.
  - Display your system context in real-time with
    custom [PS1](https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html)
    prompt (e.g., path, git branch) 
- __Data Project Templates__
  - Rapidly generate data project scaffolding
    with a suite of interoperable [copier](https://copier.readthedocs.io/en/stable/) project templates.
  - Each template provides a layer of abstraction over an open-source data tool (e.g., Python)
    and incorporates relevant best practices and patterns.
  - All projects run in isolated Docker containers which helps avoid dependency conflicts
    and ensures cross-platform compatibility (i.e., Linux, Windows).
  - `Python` template includes... 
    - Lint with ``ruff`` and ``pre-commit``.
    - Documentation with ``sphinx``.
    - Manage dependencies with ``pdm``, ``pip-tools`` and ``pyenv``.
    - Run tests and measure coverage with ``pytest`` and ``coverage``.

## Prerequisites

> ⚠️Recommended macOS version is Sequoia 15.0> or later.

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


### Python
Let's walk through building a Python 3.11.9 project called ``some_project``.
```commandline
cd ~/repos/macos-workspace/
make python project_name=some_project
```

After you complete questionnaire, a project directory will be created in ``repos/``.

Setup your Python project development environment.
```commandline
cd ~/repos/some_project
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
