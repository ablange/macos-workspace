# 		macos-workspace
#		~~~~~~~~~~~~~~~
# 		Makefile for ``macos-workspace`` build system.
# 		Each template provides a suite of tools used
# 		at some point in the data development life cycle.
#
help:
	@echo -e "\
	\n  _ __ ___   __ _  ___ ___  ___                       \
	\n | _  _ \ / _ |/ __/ _ \/ __|__                    \
	\n | | | | | | (_| | (_| (_) \__ \__                    \
	\n |_| |_| |_|\___|\___\___/|___/                      \
	\n __      __  ___  _ __| | _____ _ __   __ _  ___ ___  \
	\n \ \ /\ / / / _ \| __| |/ / __| _ \ / _ |/ __/ _ \ \
	\n  \ V  V / | (_) | |  |   <\__ \ |_) | (_| | (_|  __/ \
	\n   \_/\_/   \___/|_|  |_|\_\___/ .__/ \__,_|\___\___| \
	\n                                                      \
	\n Please choose a template:\
	\n\
    \n   $ make <TEMPLATE> \
    \n\
	\n   setup: build your workspace \
	\n   shell: build your shell prompt \
	\n   python: install your Python core \
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


.PHONY: shell
shell:
	echo 'building your shell ... '
	cp -rf dotfiles/.bashrc ~/.bashrc
	cp -rf dotfiles/.bash_aliases ~/.bash_aliases
	cp -rf dotfiles/.bash_profile ~/.bash_profile
	source ~/.bashrc


.PHONY: git
git:
	echo 'configuring Git command line completion... '
	curl -o ~/.git-completion.bash \
 		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
	curl -o ~/.git-prompt.sh \
		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh


# 3: Python
# 	pyenv
# 	pyenv-virtualenv
# 	install 3.11 globally
# 	install 3.9-3.10 for projects
# duckdb
# airflow
# jupyter