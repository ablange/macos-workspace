# macos-workspace
Build system written in Bash designed to streamline development on macOS.


## Prerequisites
1. Core macOS developer utilities
```commandline
xcode-select --install
```

2. Change your default macOS shell to bash
```commandline
chsh -s /bin/bash
```

3. Homebrew package manager
```commandline
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

4. Install GitHub CLI
```commandline
brew install gh
gh auth
```

5. Install Docker Desktop:
https://docs.docker.com/desktop/install/mac-install/
    
## Installation
Create ``repos/`` directory and clone ``macos-workspace`` into it.
```commandline
(mkdir -p ~/repos/
gh repo clone ablange/macos-workspace ~/docs/macos-workspace)
```

Build your workspace. 
```commandline
cd ~/macos-workspace/
make setup
```


Restart shell for changes to take effect.
```commandline
exec bash
```


## Usage
To get started using your workspace, build the projects you need inside ``repos/``
and use them interdependently as needed.

For example, you can write a ``python`` package
that import into your ``notebook``
and use to transform data stored in ``duckdb`` database.
Finally, you can schedule an ``airflow`` DAG
to run once a month to refresh.

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
