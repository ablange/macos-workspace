# 		macos-workspace
#		~~~~~~~~~~~~~~~
# 		Makefile for ``macos-workspace`` build system.
# 		Each template provides a suite of tools used
# 		at some point in the data development life cycle.
#
help:
	@echo -e "\
	\n   _____ _____    ____  ____  ______                             \
	\n  /     \\__  \ _/ ___\/  _ \/  ___/  ______                     \
	\n |  Y Y  \/ __ \\  \__(  <_> )___ \  /_____/                     \
	\n |__|_|  (____  /\___  >____/____  >                             \
	\n       \/     \/     \/          \/                              \
	\n __  _  _____________|  | __  _________________    ____  ____    \
	\n \ \/ \/ /  _ \_  __ \  |/ / /  ___/\____ \__  \ _/ ___\/ __ \   \
	\n  \     (  <_> )  | \/    <  \___ \ |  |_> > __ \\  \__\  ___/   \
	\n   \/\_/ \____/|__|  |__|_ \/____  >|   __(____  /\___  >___  >  \
	\n                          \/     \/ |__|       \/     \/    \/   \
	\n Please choose a template:\
	\n\
	\n   1- python \
	\n   2- [TBD] jupyter \
	\n   3- [TBD] duckdb \
	\n   4- [TBD] airflow \
	\n\
    \n   $ make <TEMPLATE> \
    \n   e.g., $ make python \
    \n\
	\n   setup: build macOS workspace \
	\n   shell: initialize bash shell \
	\n   python_core: install Python core dependencies \
	\n   python: initialize new Python project \
	\n   [TBD] jupyter: initialize new Jupyter notebook and access via web browser \
	\n   [TBD] duckdb: initialize new DuckDB database server in a Docker container \
	\n   [TBD] airflow: initialize new Airflow scheduler in a Docker container and access via web browser \
	"


.PHONY: setup
setup: os_dependencies git shell
	echo 'building your workspace ... '


.PHONY: os_dependencies
os_dependencies:
	echo 'installing OS dependencies ...'
	brew install \
			openssl  \
			readline \
			sqlite3  \
			xz       \
			zlib     \
			tcl-tk   \
			wget   \
			docker


.PHONY: git
git:
	echo 'configuring Git command line completion... '
	curl -o ~/.git-completion.bash \
 		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
	curl -o ~/.git-prompt.sh \
		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh


.PHONY: shell
shell:
	echo 'building your shell ... '
	cp -rf dotfiles/.bashrc ~/.bashrc
	cp -rf dotfiles/.bash_aliases ~/.bash_aliases
	cp -rf dotfiles/.bash_profile ~/.bash_profile
	source ~/.bashrc


.PHONY: python_core
python:
	echo 'installing Python core ... '
	brew install \
			pyenv \
			pyenv-virtualenv
	pyenv install \
			3.11.9 \
			3.10.14 \
			3.9.19
	pyenv global 3.11.9
	mkdir -p ~/repos/


# TODO: duckdb
# TODO: airflow
# TODO: jupyter
