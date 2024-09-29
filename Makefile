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


.PHONY: shell
shell:
	echo 'building your shell ... '
	cp -rf dotfiles/.bash_aliases ~/.bash_aliases
	cp -rf dotfiles/.bash_profile ~/.bash_profile
	cp -rf dotfiles/.bashrc ~/.bashrc
	source ~/.bashrc


# shell
# 	bash prompt
# 	bash aliases
# git
# 	git config
# 	git command autocomplete
# 	git branch name autocomplete
# python
# 	pyenv
# 	pyenv-virtualenv
# 	install 3.11 globally
# 	install 3.9-3.10 for projects
# duckdb
# airflow
# jupyter