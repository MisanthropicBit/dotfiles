# Set up general environment variables
export PATH=$PATH:/usr/local/bin

# Always use UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Editor environment variables
export EDITOR="nvim"
export HOMEBREW_EDITOR="nvim"
export GIT_EDITOR="nvim"

# Erase duplicates in history
export HISTCONTROL=erasedups

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion"
fi

# Change directory color to cyan
# a = black
# b = red
# c = green
# d = brown
# e = blue
# f = magenta
# g = cyan
# h = light grey (white in iTerm2)
# x = Default fore- or background color
#
# Use uppercase letters for bold colors
#
# Ordering:
# 1.  Directories
# 2.  Symbolic links
# 3.  Sockets
# 4.  Pipes
# 5.  Executables
# 6.  Block special
# 7.  Character special
# 8.  Executables with setuid bit set
# 9.  Executables with setgid bit set
# 10. Directories writable to others, with sticky bit set
# 11. Directories writable to others, without sticky bit set
#
# Also see http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/
export LSCOLORS='ExFxxxxxBx'

if [ -f ~/.bash_powerprompt.sh ]; then
    export BASH_POWERPROMPT_DIRECTORY="/Users/albo/Dropbox/projects/bash/bash_powerline/"
    export BASH_POWERPROMPT_THEME=random
    source ~/.bash_powerprompt.sh
    export PROMPT_COMMAND=__bash_powerprompt
fi

# MacTeX needs to be exported on El Capitan due to Apple's new rootless feature
export PATH=$PATH:/Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin

# Make sure /usr/local/sbin is in the path for Homebrew installs
export PATH="$PATH:/usr/local/sbin"

# Add cabal install path to PATH
export PATH="$PATH:$HOME/.cabal/bin"
