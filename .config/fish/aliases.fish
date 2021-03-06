# A bunch of useful fish aliases ported from my bash config

#alias tree      "tree -C"
alias ..        "cd .."
alias ..2       "cd ../.."
alias ..3       "cd ../../.."
alias ..4       "cd ../../../.."
alias ag        "ag --color-line-number\"\" --color-path=\"1;34\" --color-match=\"1;31\" --path-to-ignore ~/.agignore"
alias aliases   "$EDITOR ~/.config/fish/aliases.fish"
alias c         "pbcopy"
alias ccat      "pygmentize -g -f terminal16m -O linenos=1,style=monokai"
alias cg        "grep -I -n --color=always --exclude=tags"
alias dbox      "~/Dropbox/"
alias fucking   "sudo"
alias gitconfig "$EDITOR ~/.gitconfig"
alias gofish    "source ~/.config/fish/config.fish"
alias gstatus   "nvim -c 'Gstatus | only'"
alias l         "ls -laGh"
alias ll        "clear; l"
alias lz        "ls -laGhS"
alias nvimdiff  "nvim -d"
alias nvimrc    "$EDITOR ~/.config/nvim/init.vim"
alias path      "echo $PATH | tr ':' '\n' | sort -u"
alias projects  "cd ~/Dropbox/projects"
alias research  "cd ~/research"
alias rg        "cg -rn"
alias todo      "cg --exclude-dir=tmp -HIni ' todo:'"
alias v         "pbpaste"
alias vbundle   "cd ~/.vim/bundle"
alias vh        "vimhelp"
alias vimrc     "$EDITOR ~/.vimrc"

function tophist -d "Show the top 'n' most used commands"
    set -l top "$argv[1]"

    if test -z "$top"
        set top 3
    end

    history | awk 'BEGIN {FS="|"}{print $1}' | awk '{print $1}' | sort | uniq -c | sort -nr | head -n "$top"
end

function sve -d "Display or activate a virtual environment"
    if test -z "$argv[1]"
        if test -n "$VIRTUAL_ENV"
            printf "Current virtual environment is '$VIRTUAL_ENV'\n"
        else
            printf "No currently active virtual environment\n"
        end
    else
        if test -e "$argv[1]/bin/activate.fish"
            source "$argv[1]/bin/activate.fish"
            printf "%s\n" "Virtual environment '$VIRTUAL_ENV' is active"
        else
            printf "'$argv[1]' is not a virtual environment"
        end
    end
end

function pup -d "Upgrade pip using pip"
    command pip install --upgrade pip
end

function weather -d "Show the current weather in the terminal"
    set -l arg "$argv[1]"

    if test -z $arg
        curl -s wttr.in
    else
        curl -s "wttr.in?$arg"
    end
end

#function bpp
#    echo "$FISH_POWERPROMPT_THEME"
#end

#function bpprand -d "Select a random prompt theme"
#    set --export FISH_POWERPROMPT_THEME random
#end

#if pip list | grep -iw "markdown" > /dev/null
#    function mdr -d "Render a markdown file as html"
#        for filename in $argv
#            # TODO
#        end
#    end
#end

#function man -d "Open a man page with vim"
#    command man $@ | col -b | vim -R -c "set ft=man nomod nolist" -
#end
