function fish_hybrid_key_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end

    fish_vi_key_bindings --no-erase
end

function try_source -a path
    if test -e "$path"
        source "$path"
    end
end

set --universal fish_color_command 00c5d7 darkcyan
set --local script_dir (dirname (status -f))
set --universal PYENV_ROOT "$HOME/.pyenv"

set -x LANG en.UTF-8
set -x N_PREFIX ~/.n
set -x EDITOR     nvim
set -x GIT_EDITOR nvim
set -x VISUAL     nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x MYSQL_PS1 "mysql v\v [\U][\d]> "
set -x BAT_THEME OneHalfDark
set -x FZF_CTRL_T_OPTS '--multi --bind="ctrl-s:select,ctrl-u:deselect,ctrl-f:reload(find . -type f \$dir),ctrl-d:reload(find . -type d \$dir)" --preview="bat -n --color=always {}" --cycle --walker=file,follow,hidden'
set -x FZF_DEFAULT_OPTS "--color='pointer:bright-blue,marker:bright-green' --height=50% --pointer='󰜴' --marker=' ' --bind='ctrl-n:preview-page-down,ctrl-p:preview-page-up' --cycle"
set -x RIPGREP_CONFIG_PATH ~/.ripgreprc
set -x HOMEBREW_NO_ANALYTICS 1
set -x MINIKUBE_IN_STYLE false

fish_add_path /opt/local/bin /usr/local/bin /opt/homebrew/bin
fish_add_path ~/.npm-global/bin "$PYENV_ROOT/bin" ~/projects/c/terminal_blocks
fish_add_path ~/google-cloud-sdk/bin ~/repos/cloud-sql-proxy/
fish_add_path -p "$N_PREFIX/bin"
fish_add_path ~/.luarocks/bin /opt/local/share/luarocks/bin
fish_add_path ~/.cargo/bin

try_source "$script_dir/work_env.fish"
try_source "$script_dir/aliases.fish"
try_source "$script_dir/abbreviations.fish"
try_source "$script_dir/work_aliases.fish"
try_source "$script_dir/work-config.fish"
try_source "$script_dir/key-bindings.fish"
try_source "~/.iterm2_shell_integration.fish"

if type -q "fd"
    set -x FZF_DEFAULT_COMMAND "fd -tf --color=never"
    set -x FZF_ALT_C_COMMAND "fd -td --color=never"
end

# Set this after setting FZF_* environment variables
if type -q "fzf"
    fzf --fish | source
end

if type -q "kubectl"
    kubectl completion fish | source
end

if type -q "docker"
    mkdir -p ~/.config/fish/completions
    docker completion fish > ~/.config/fish/completions/docker.fish
end

# Use neovim as a pager for manpages
if type -q "nvim"
    set -x MANPAGER "nvim +Man!"
end

if test -x pyenv
    status --is-interactive; and source (pyenv init -|psub)
end

if type -q starship
    starship completions fish | source
    starship init fish | source
else
    fish_config prompt choose scales
end
