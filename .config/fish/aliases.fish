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
alias dbox      "~/Dropbox/"
alias fucking   "sudo"
alias gitconfig "$EDITOR ~/.gitconfig"
alias gofish    "source ~/.config/fish/config.fish"
alias gstatus   "nvim -c 'G | only'"
alias l         "ls -laGh"
alias ll        "clear; l"
alias lz        "ls -laGhS"
alias nv        "nvim"
alias nvd       "nvim -d"
alias nvc       "nvim -p (git diff --name-only --diff-filter=U --relative)"
alias nvm       "nvim -p (git diff --name-only --diff-filter=M --relative)"
alias nvrc      "$EDITOR ~/.config/nvim/init.vim"
alias path      "echo $PATH | tr ':' '\n'"
alias projects  "cd ~/Dropbox/projects"
alias research  "cd ~/research"
alias todo      "rg --exclude-dir=tmp -HIni ' todo:'"
alias v         "pbpaste"
alias vbundle   "cd ~/.vim/bundle"
alias vh        "vimhelp"
alias vimrc     "$EDITOR ~/.vimrc"

set --local script_dir (dirname (status -f))
set --local work_aliases "$script_dir/work_aliases.fish"

if test -f "$work_aliases"
    source "$work_aliases"
end

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

function npa -d "Run multiple npm scripts"
    for script in $argv
        npm run "$script"

        if test $status -gt 0
            break
        end
    end
end

function dh -d "Fuzzy search directory history"
    set -l result (
        dirh |
        fzf --with-nth=2 --tiebreak=end --preview='tree -C -L 1 -hp --dirsfirst {2}' |
        string split -f2 ') '
    ); and cd "$result"
end

function git_fzf_branches -d "Select a git branch"
    set -l branch (
        git --no-pager branch -v --color=always |
        fzf --ansi --no-multi --preview='git log -5 {1} | bat --color=always --style=plain' |
        string trim |
        string split -f1 ' '
    )

    if test $status -eq 0
        if status is-interactive
            commandline -it "$branch"
        else
            git checkout "$branch"
        end
    end

    # Necessary to get the prompt back again otherwise you have to press enter
    # yourself or something similar to get the prompt back
    commandline --function repaint
end

function git_fzf_log -d "Search the git log"
    set -l log_format '%C(bold blue)%h%C(reset) %C(cyan)%ad%C(reset) → %C(yellow)%d%C(reset) %C(normal)%s%C(reset) %C(dim normal)[%an]%C(reset)'

    set -l log_line (
        git log --color=always --format=format:$log_format --date=short |
        fzf\
            --ansi --no-multi \
            --prompt 'Git log> ' \
            --preview 'git show --color=always --stat --patch {1}' \
            --query (commandline --current-token)
    )

    if test $status -eq 0
        set -l commit (string split -f1 ' ' log_line)
        commandline --current-token --replace "$commit"
    end

    commandline --function repaint
end

function git_fzf_commits -d "Search commit history"
    set -l log_format "%C(auto)%h %<(70,trunc)%s %C(black)%C(bold)%cr%C(reset) by %C(magenta)%an"
    set -l extract_commit_sha_cmd 'grep -o "[a-f0-9]\{8\}" | tr -d "\n"'

    set -l log_line (
        git --no-pager log --color=always --format="$log_format" |
        fzf --ansi --no-sort --no-multi --reverse --tiebreak=index \
            --prompt 'Git commit> ' \
            --bind "ctrl-y:execute-silent(echo {} | $extract_commit_sha_cmd | pbcopy)" \
            --preview "git show --color=always --shortstat --patch (echo {} | $extract_commit_sha_cmd)" |
        grep -o "[a-f0-9]\{8\}"
    )

    if test $status -eq 0
        if status is-interactive
            commandline --current-token --replace "$log_line"
        end
    end

    commandline --function repaint
end

function git_fzf_graph -d "Search git log graph"
    set -l log_format "%C(auto)%h %<(70,trunc)%s %C(black)%C(bold)%cr%C(reset) by %C(magenta)%an"
    set -l extract_commit_sha_cmd 'grep -o "[a-f0-9]\{8\}" | tr -d "\n"'

    set -l log_line (
        git --no-pager log --graph --color=always --format="$log_format" |
        fzf --ansi --no-sort --no-multi --reverse --tiebreak=index \
            --prompt 'Git graph commit> ' \
            --bind "ctrl-y:execute-silent(echo {} | $extract_commit_sha_cmd | pbcopy)" \
            --preview "git show --color=always --shortstat --patch (echo {} | $extract_commit_sha_cmd)" |
        grep -o "[a-f0-9]\{8\}"
    )

    # --bind="ctrl-m:execute:(grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF' {} FZF-EOF"

    if test $status -eq 0
        if status is-interactive
            # set -l commit (string split -f1 ' ' log_line)
            # commandline --current-token --replace "$log_line"
            commandline -it "$log_line"
        end
    end

    commandline --function repaint
end

function G -d "execute git commands and open them in vim/nvim"
    # Inspired by fugitive.vim
    $EDITOR -c "G $argv | only"
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
