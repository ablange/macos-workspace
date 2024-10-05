# macos-workspace
Build system written in Bash designed to streamline development on macOS.


## Features
- __Bash Shell Manager__
  - Manage and rebuild Bash shell with [Makefile](https://www.gnu.org/software/make/manual/make.html) commands.
  - Store dotfiles (e.g., `.bashrc`) in version control and backup or branch as needed.
  - Reproduce 100% of terminal setup on any macOS machine.
  - Custom [PS1](https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html)
    terminal prompt with development context (e.g., path, git branch).
- __Data Product Development Templates__
  - Rapidly prototype data products with a suite of [copier](https://copier.readthedocs.io/en/stable/) project templates.
  - Handle software-related aspects of data projects so you can focus on the data itself.
  - Ensure cross-platform compatibility and avoid dependency conflicts
    by running each project in an isolated Docker container.
  - Templates are interoperable so projects once initialized share
    local network connectivity (e.g., database).
  - Templates include...
    - `Python`:
      - Run Python 3.11 in a virtual environment with Pyenv and Docker.
      - Manage Python and OS dependencies with Pdm.
      - Lint, format, and style code on every commit with Ruf and Pre-commit.
      - Generate documentation from code docstrings using Sphinx.
      - Measure and enforce unit test coverage with pytest and coverage.
    - __`Duckdb`__: Coming soon!   


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
* jupyter
* airflow


### Python
Let's walk through building a Python 3.11.9 project called ``some_project``.
```commandline

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
