# macOS workspace: The definitive guide to working with data on macOS
Streamline data development on macOS with build system written in Bash.

> _“Give me six hours to chop down a tree, and I will spend the first four sharpening the axe.”_
— Abraham Lincoln

 
# Preface
Honest Abe understood the correlation between tools and productivity. 
Sure, you could chop that tree with a steak knife, just don't forget a flashlight for when it gets dark! 
Abe understood how blades work and decided to optimize for sharpness, ultimately leading to faster success.


# Introduction
Setting up a new machine for Python development 
and data analysis can feel like navigating a labyrinth. 
Between choosing tools and managing dependencies, 
the process can be time-consuming and frustrating 
especially when all you want to do is work with data.

In this post, we'll introduce the macos-workspace project--
a build system written in Bash designed to automatically 
install and configure various open-source data tools--
all neatly wrapped in a command line interface. 
By fully automating the setup, we eliminate the manual 
hassle of selecting and installing each tool individually.

The macOS-workspace project has four "templates" 
(e.g., python, jupyter, airflow, duckdb). 
Each template serves a specific purpose 
in the data development lifecycle. All templates and tools 
are pre-selected based on compatibility, usability, and community support.

During this post, we will use the python template to initialize multiple projects, 
manage dependency conflicts, lint and format code, 
generate documentation, and measure test coverage. 
Along the way, we will explore the rationale behind certain 
choices made in the template's design. By the end of the post, 
you'll be able to write, run, and debug Python projects on macOS with ease.


# Getting Started
- Install package manager--homebrew
- Install GitHub CLI--gh
- Install macos-workspace
```commandline
# Core macOS developer utilities
xcode-select --install
# Install Homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install GitHub CLU
brew install gh
# Clone macos-workspace & install
mkdir ~/repos/
cd ~/repos/
gh clone macos-workspace
cd ~/repos/macos-workspace/
make setup
# Restart shell, all done!
```
- Review bash shell prompt PS1, take screenshot and highlight.
- Review bash aliases, show examples.
- List available templates


# Python Template
## Initialize
- Initialize new project using python template (``make python``)
- Change into new project directory & start env


## Manage dependencies (pdm)
- Explain pdm
- Demo


## Lint and format (ruf)
- Explain ruf
- Demo


## Measure test coverage (pytest)
- Explain ruf
- Demo


## Generate documentation (mkdocs)
- Explain mkdocs
- Demo


## Debug in IDE
- Explain how to quickly debug in JetBrains (.devcontainer)?
- Explain how to quickly debug in VSCode (.devcontainer)?


## What else is available?
- List all other available features embedded within template note previously mentioned.


# Conclusion
- Summarize what did we accomplish?
- Summarize what did we learn? What are key takeaways?
- Reiterate benefits of automation.