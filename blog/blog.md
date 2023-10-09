# macOS workspace
Bash script for automatically configuring macOS for Python development.

## Preface
> _“Give me six hours to chop down a tree, and I will spend the first four sharpening the axe.”_
— Abraham Lincoln

Configuring a machine for software development is tedious at best, and an emotional roller coaster at worst.
After purchasing a new Apple MBP 13" M3 Pro and spending a few hours setting everything up how I like it,
I decided to automate the setup and document the rationale behind certain decisions made along the way.

My hope is others will enjoy and maybe even use the project for some or all of their workstation.

## Introduction
In this post, we'll learn how to configure a macOS user account for Python development, 
with an emphasis on boosting productivity and accelerating context switching.
We'll explain how to connect to GitHub and run the initial setup script using your terminal.
From there, we'll use Makefile commands to build a Python environment locally.
Finally, we'll install an IDE and debug a Python process.

At the end of this post, you'll gain a detailed understanding of how to write, run, debug, & test
Python locally on any macOS machine in just a few minutes.

## Table of Contents
1. Why macOS?
2. Automated setup script
3. Python project scaffolding
4. Python debugger in IDE

## Why macOS?
It is important to choose an operating system that improves your computing experience.
Let's evaluate the most popular OS choices for Apple hardware:

- **Linux** distributions are simple, gimmick-free, and built for software development.
  Linux shines when it comes to customization and compatibility with open-source tools.
  The terminal experience is powerful. But most Linux GUIs are slow and ugly. 
  This is sufficient for server maintenance, but falls short for day-to-day use.

- **Windows** is reliable and has an excellent presentation layer.
  Despite recent advancements in WSL2, it is challenging and time-consuming 
  to debug a process. Customization is limited. Most benefits exist at the enterprise level, 
  and so for personal use I think there are better options.

- **macOS** is elegant, responsive, and easy to use.
  Apple's [XNU kernel](https://github.com/apple/darwin-xnu?ref=itsfoss.com)
  is a relative of Unix, so you get all the software compatibility benefits of Linux,
  alongside the convenience of Apple services. Not to mention better hardware compatibility than
  Linux, and more customizable options than Windows.

I prefer macOS because of the superior user experience and native Unix-like experience.

> "_Apple's rewrite of their operating system has a core based [on] various BSD technologies. 
> The command set is derived from FreeBSD. Thus, besides having an exciting user interface,
> [macOS] is representative of the BSD strain of free Unix-like systems._" <sup>1</sup>
— O’Reilly, _Unix in a Nutshell_ 

TODO: Install rectangle; Install iTerm?


## Automated setup script

### Git SSH key
Before I can do anything else, I need to create my Git SSH key

```shell
# Install XCode developer tools. 
xcode-select --install
# Create private/public key pair
ssh-keygen -t ed25519 -C "yourEmail@site.com"
# Copy public key to clipboard
pbcopy < /.ssh/{YOUR_PUBLIC_KEY_FILE}.pub
# Paste public key into GitHub account here:
# https://github.com/settings/keys
```


### Run script
```shell
# Clone into repos/
git clone https://github.com/ablange/macos-workstation
cd ~/repos/macos-workstation
make setup
```

This automatically installs and configures the following:
- Shell
- Git
- Homebrew
- Python core


### Shell
Let's create a `.bash_profile` file in our home directory to customize
our terminal prompt to look like this:
```
(yourUser@yourMachine)(YourVirtualEnv)(your/working/dir/)(your-git-branch)
$ echo 'is this thing on?'
```
TODO: Finish bash shell config.
TODO: Create bash/git aliases.


### Git
TODO: Set git global settings.
TODO: Figure out git autocomplete and branch display in terminal prompt.


### Python Core
[Homebrew](https://brew.sh/) is by far the best macOS packager 
for its simplicity and frequent patches.
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

[pyenv](https://github.com/pyenv/pyenv) is an incredible tool 
that makes it really easy to install and manage 
multiple Python versions on your machine.
```shell
brew install pyenv
```

[pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) is a pyenv extension
used to simulatenously manage multiple Python virtual environments.
```shell
brew install pyenv-virtualenv
#  Add pyenv virtualenv-init to your shell to enable auto-activation of virtualenvs
eval "$(pyenv virtualenv-init -)"
```

Thank you for reading! 
In a future post, we'll explore more advanced Python projects that use this template like Airflow.

## Python project scaffolding
TODO: Use temple python to install a project.

## Python debugger in IDE
TODO: Maybe user VSCode to setup debugger?

## Citations
[1]: Robbins, A. (2005). _Unix in a nutshell_, 4th edition. O’Reilly.
