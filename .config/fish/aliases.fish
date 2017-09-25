# A bunch of useful fish aliases ported from my bash config

function sfc -d "Source the fish user config"
    source "~/.config/fish/config.fish"
end

function .. -d "Go up one directory level"
    cd ".."
end

function ..3 -d "Go up three directory levels"
    cd "../../.."
end

function ..4 -d "Go up four directory levels"
    cd "../../../.."
end

function c -d "Copy into the clipboard"
    pbcopy
end

function v -d "Past from the clipboard"
    pbcopy
end

function fucking -d "JUST DO IT!"
    sudo $argv
end

function l
    ls -laGh
end

function ll
    clear and ls -laGh $argv
end

function projects
    cd "~/Dropbox/projects"
end

function todo
    ag "TODO|todo"
end

function vbundle
    cd "~/.vim/bundle"
end

function vh
    vim -c "help $1 | only"
end

function bpp
    echo "$FISH_POWERPROMPT_THEME"
end

function bpprand -d "Select a random prompt theme"
    set --export FISH_POWERPROMPT_THEME random
end

function cg
    grep -I --color=always --exclude=tags
end

function rg
    cgrep -r
end

if type -q pygmentize
    function hi -d "Syntax highlight input argument"
        pygmentize -O style=fruity -f terminal16m $argv[1] | less -r
    end
end

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

#function tophist -d "List the top n most used commands"
#    set top $argv[1]

#    if -z $top
#        set top 3
#    end

#    history | awk '{print $argv[2]}' | awk 'BEGIN {FS="|"}{print $argv[1]}' |\
#        sort | uniq -c | sort -nr | head -n $top
#end
