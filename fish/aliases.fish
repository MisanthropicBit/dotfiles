alias ..        "cd .."
alias ..2       "cd ../.."
alias ..3       "cd ../../.."
alias ..4       "cd ../../../.."
alias aliases   "$EDITOR ~/.config/fish/aliases.fish"
alias c         "pbcopy"
alias dbox      "~/Dropbox/"
alias fucking   "sudo"
alias g         "git"
alias gitconfig "$EDITOR ~/.gitconfig"
alias gofish    "source ~/.config/fish/config.fish"
alias kc        "kubectl"
alias l         "ls -laGh"
alias ll        "clear; l"
alias lz        "ls -laGhS"
alias nv        "nvim"
alias nvc       "nvim (git diff --name-only --diff-filter=U --relative)"
alias nvd       "nvim -d"
alias nvm       "nvim (git diff --name-only --diff-filter=MA --relative && git diff --name-only --diff-filter=MA --relative --cached)"
alias nvl       "nvim (git diff-tree --no-commit-id --name-only -r HEAD)"
alias nvrc      "$EDITOR ~/.config/nvim/init.lua"
alias path      "echo $PATH | tr ':' '\n'"
alias todo      "rg -Hni -A3 ' todo:'"
alias tree      "tree -C"
alias v         "pbpaste"

set --local script_dir (dirname (status -f))
set --local work_aliases "$script_dir/work_aliases.fish"

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
    if test (count $argv) -eq 0
        npm run
    else
        for script in $argv
            npm run "$script"

            if test $status -gt 0
                break
            end
        end
    end
end

function dh -d "Fuzzy search directory history"
    set -l result (
        dirh |
        grep -v '^\s*$' |
        fzf --ansi --with-nth=2 --tiebreak=end --preview='tree -C -L 1 -hp --dirsfirst {1}' |
        string split -f2 ') '
    ); and cd "$result"
end

function sp -d "Fuzzy search projects directory"
    set -l result (
        fd --type d . ~/projects ~/repos --maxdepth 2 |
        fzf --ansi --tiebreak=end --preview='tree -C -L 1 -hp --dirsfirst {1}'
    ); and cd "$result"
end

function git_fzf_branches -d "Select a git branch"
    set -l branch (
        git --no-pager branch -v --color=always --sort=-committerdate |
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
            --preview "git show --color=always --stat --patch (echo {} | $extract_commit_sha_cmd)" |
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

function nvdv -d "Open Diffview in neovim"
    nvim -c "DiffviewOpen"
end

function tw -a workspace -d "Set the opentofu workspace"
    set -l workspaces (tofu workspace list)

    if test -z "$workspace"
        set -l height (math (count $workspaces) + 2)
        set workspace (string split -n " " "$workspaces" | fzf --prompt "Select workspace> " --pointer "󱁢 " --color="pointer:215" --height "$height")
    end

    if test -z "$workspace"
        return
    end

    set workspace (string trim -r "$workspace")

    tofu workspace select "$workspace"

    if test $status -ne 0
        return $status
    end
end

function config -d "Select a fish configuration file"
    fd --type f . ~/.config/fish |
        fzf --ansi --preview='bat --color=always --style=plain {}' --bind "enter:become($EDITOR {})"
end

if test -f "$work_aliases"
    source "$work_aliases"
end
