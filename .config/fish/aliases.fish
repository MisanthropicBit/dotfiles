# A bunch of useful fish aliases ported from my bash config

alias ..        "cd .."
alias ..2       "cd ../.."
alias ..3       "cd ../../.."
alias ..4       "cd ../../../.."
alias ag        "ag --color-line-number\"\" --color-path=\"1;34\" --color-match=\"1;31\" --path-to-ignore ~/.agignore"
alias aliases   "$EDITOR ~/.aliases"
alias c         "pbcopy"
alias ccat      "pygmentize -g -f terminal16m -O linenos=1,style=monokai"
alias cg        "grep -I -n --color=always --exclude=tags"
alias rg        "cg -rn"
alias dbox      "~/Dropbox/"
alias fucking   "sudo"
alias gitconfig "$EDITOR ~/.gitconfig"
alias gofish    "source ~/.config/fish/config.fish"
alias l         "ls -laGh"
alias lz        "ls -laGhS"
alias ll        "clear; l"
alias tree      "tree -C"
alias nvimrc    "$EDITOR ~/.config/nvim/init.vim"
alias path      "echo $PATH | tr ':' '\n' | sort -u"
alias projects  "cd ~/Dropbox/projects"
alias todo      "cg --exclude-dir=tmp -HIni ' todo:'"
alias v         "pbpaste"
alias vbundle   "cd ~/.vim/bundle"
alias vh        "vimhelp"
alias vimrc     "$EDITOR ~/.vimrc"

function tophist -d "Show the top 'n' most used commands"
    set -l top "$1"

    if -z "$top"
        set -l top 3
    end

    history | awk '{print $2}' | awk 'BEGIN {FS="|"}{print $1}' | sort | uniq -c | sort -nr | head -n $top
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
