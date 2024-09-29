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
	chmod +x ./setup.sh
	./setup.sh

.PHONY: shell
shell:
	echo 'building your shell ... '
	cp -rf dotfiles/.bash_aliases ~/.bash_aliases
	cp -rf dotfiles/.bash_profile ~/.bash_profile
	cp -rf dotfiles/.bashrc ~/.bashrc
	source ~/.bashrc
