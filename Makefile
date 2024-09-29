# Makefile for workflows

# Print usage of main targets when user types "make" or "make help"
help:
	@echo -e "Please choose one of the following targets:\
	\n   setup: build your workspace \
	\n   shell: build your shell prompt \
	\n   python: install your Python core \
	"


.PHONY: setup
setup:
	echo 'building your workspace ... '
	os_dependencies

# 0: OS dependencies
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

# 1: Shell
.PHONY: shell
shell:
	echo 'building your shell ... '
	cp -rf dotfiles/.bashrc ~/.bashrc
	cp -rf dotfiles/.bash_aliases ~/.bash_aliases
	cp -rf dotfiles/.bash_profile ~/.bash_profile
	source ~/.bashrc


# 1. Shell
# 2. Git
# 	2a. git command autocomplete
# 	2b. git branch name autocomplete
# 	2c. git config ``name`` & ``email``
# 3: Python
# 	pyenv
# 	pyenv-virtualenv
# 	install 3.11 globally
# 	install 3.9-3.10 for projects
# duckdb
# airflow
# jupyter