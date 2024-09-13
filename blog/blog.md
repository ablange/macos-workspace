# macOS workspace: The definitive guide to running Python on macOS
Turn your macOS into a Python Powerhouse using the macOS-workspace build system written in Bash.


> _“Give me six hours to chop down a tree, and I will spend the first four sharpening the axe.”_
— Abraham Lincoln

 
# Preface
Honest Abe understood the correlation between tools and productivity. 
Sure, you could chop that tree with a steak knife, just don't forget a flashlight for when it gets dark! 
Abe understood how blades work and decided to optimize for sharpness, ultimately leading to faster success.


# Introduction
Setting up a new machine for Python development can feel like navigating a labyrinth. 
Between choosing tools and managing dependencies, the process can be time-consuming and frustrating, 
especially when all you want to do is write code, not sift through documentation. 
This is where DevOps automation can be a game-changer.

In this post, we'll introduce the macos-workspace project a local build system 
written in Bash designed to streamline the Python installation process 
and simplify virtual environment management--all neatly wrapped in a custom shell prompt interface 
intended to boost productivity and accelerate context switching. 
By fully automating the setup, we eliminate the manual hassle and free you up to write code.

During the post, we will discuss the rationale at each layer in the workspace. 
Then we will explain the installation process step-by-step. 
Finally, we will initialize a Python project locally. 
By the end of this post, you'll be able to seamlessly write, run, 
and debug multiple Python projects on macOS machine with ease.


# Layers
Let's define each layer in our workspace, and elaborate on what will be installed and why certain tools were chosen.
a. Operating System: Why macOS over Windows for development?
b. Shell: Why Bash over Zsh? 
c. Package Manager: Why Nix over Homebrew? Discuss dependency management.
d. Python Environment Manager: Why Pyenv and Pyenv-Virtualenv over Virtualenv and Conda? 
   Discuss managing multiple Python versions and virtual environments effortlessly. 
   Explain how template will "compile requirements" using options. 
   Explore possibility of generating new Python project in Docker container as opposed to venv only.
e. IDE, Tools and Services: 
   Explain how to configure IDE to debug Python. 
   Explain Rectangle, and other productivity tools.


## Operating System
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


## Shell
```shell
brew install pyenv-virtualenv
#  Add pyenv virtualenv-init to your shell to enable auto-activation of virtualenvs
eval "$(pyenv virtualenv-init -)"
```


## Package Manager
[Homebrew](https://brew.sh/) is by far the best macOS packager 
for its simplicity and frequent patches.
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


## Python Environment Manager
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


## IDE, Tools & Services
TODO


# Getting Started
## Git SSH key
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


## Install the workspace
```shell
# Clone into repos/
git clone https://github.com/ablange/macos-workstation
cd ~/repos/macos-workstation
make install  # one-time installation
make setup    # start your workspace!
```


# Python project template
TODO 


# Citations
[1]: Robbins, A. (2005). _Unix in a nutshell_, 4th edition. O’Reilly.
