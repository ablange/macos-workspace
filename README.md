# macOS Workstation
Detailed walk-through of a data engineer's personal macOS toolchain.

## Preface
The relevancy of Moore's law has subsided, and so too has my motivation to buy a new computer.
Instead of buying new hardware, I prefer to create a new account (i.e., "workstation")
on my old 2017 MacBook Pro. In this post, we'll walk through the steps I take to prepare 
a fresh macOS account for Python development. 

## Why macOS?
Operating systems are fascinating.
They are omnipresent and expected to run bug-free without security flaws.
They are used by tech-savy grandparents, software hobbyists, and corporations worldwide.
When it comes to selecting an OS, it is important to choose one that improves the computing experience.

Let's evaluate the most popular OS choices under the lens of open-source Python development:

- **Windows** is reliable and has an excellent presentation layer.
  Despite recent advancements in WSL2, there are hurdles to overcome
  in terms of linux development. It is challenging and time-consuming to debug a process.
  Most benefits exist in the context of an enterprise, so for personal development
  I think there are better and easier options.
  
- **Linux** distributions are simple, gimmick-free, and built for software development.
  Linux shines when it comes to installing and running various open source tools and applications.
  The terminal experience is powerful. However, most linux GUIs are slow and ugly compared 
  to their commercial rivals. This is sufficient for server maintenance, 
  but falls short for projects and day-to-day use.

- **macOS** is elegant, responsive, and easy to use. Most developers know that 
  [Apple's XNU kernel](https://github.com/apple/darwin-xnu?ref=itsfoss.com),
  used in macOS and iOS, is a relative of Unix. This means anything you can install on linux you can 
  can install on macOS. So you get all the open-source compatibility, along with all the incredible
  features the designers at Apple have worked on for decades to provide.


*Disclaimer: yes, I own several Apple products.
  I find that Apple offers a superior value proposition in terms of user experience, durability, 
  and compatibility.* 


## Walk-through

### Version Control (Git)
Before I can do anything else, I need to create my Git SSH key
so I can clone and push code.
```shell
# Create private/public key pair
ssh-keygen -t ed25519 -C "yourEmail@site.com"
# Copy public key to clipboard
pbcopy < /.ssh/{YOUR_PUBLIC_KEY_FILE}.pub
# Paste public key into GitHub account here:
# https://github.com/settings/keys
```


### Package Manager (Homebrew)
[Homebrew](https://brew.sh/) is by far the best macOS packager 
for its simplicity and frequent patches.
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


### Python (pyenv)
[pyenv](https://github.com/pyenv/pyenv) is an incredible tool 
that makes it really easy to install and manage 
mutliple Python versions on your machine. 

```shell
brew install pyenv
```

[pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) is a pyenv extension
used to simulatenously manage multiple Python virtual enviornments.
```shell
brew install pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
```


### Shell (Bash)
Let's create a `.bash_profile` file in our home directory to customize
our terminal prompt to look like this:
```
(yourUser@yourMachine)(YourVirtualEnv)(your/working/dir/)(your-git-branch)
$ echo 'is this thing on?'
```


TODO: Finish bash shell config.
TODO: Create bash/git aliases.
TODO: Figure out git autocomplete and branch display in terminal prompt.


## Project: Hello Python World
TODO: Create a project directory structure.

TODO: Create a Python 3.10 virtual env.

TODO: Setup a pre-commit hook.

TODO: Debug in PyCharm.
