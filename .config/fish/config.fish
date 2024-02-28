set --universal fish_color_command 00c5d7 darkcyan

set --local script_dir (dirname (status -f))

if test -e "$script_dir/aliases.fish"
    source "$script_dir/aliases.fish"
end

set --universal PYENV_ROOT "$HOME/.pyenv"

# Use neovim as a pager for manpages
if type nvim &> /dev/null
    set -x MANPAGER "nvim +Man!"
end

if test -x pyenv
    status --is-interactive; and source (pyenv init -|psub)
end

set -x N_PREFIX ~/.n
set -x EDITOR     nvim
set -x GIT_EDITOR nvim
set -x VISUAL     nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x MYSQL_PS1 "mysql v\v [\U][\d]> "
set -x BAT_THEME OneHalfDark
set -x FZF_DEFAULT_COMMAND "fd -tf --color=never"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND --search-path \$dir"
set -x FZF_CTRL_T_OPTS '--multi --bind="ctrl-s:select,ctrl-u:deselect,ctrl-f:reload(find . -type f \$dir),ctrl-d:reload(find . -type d \$dir)" --preview="bat -n --color=always {}" --cycle'
set -x FZF_ALT_C_COMMAND 'fd -td --color=never'
set -x FZF_DEFAULT_OPTS "--color='pointer:bright-blue,marker:bright-green' --height=50% --pointer='⇨ ' --marker='✓' --bind='ctrl-n:preview-page-down,ctrl-p:preview-page-up' --cycle"
set -x LUA_PATH '/opt/local/share/lua/5.1/?.lua;/opt/local/share/lua/5.1/?/init.lua;/opt/local/lib/lua/5.1/?.lua;/opt/local/lib/lua/5.1/?/init.lua;./?.lua;./?/init.lua;~/.luarocks/share/lua/5.1/?.lua;~/.luarocks/share/lua/5.1/?/init.lua;/opt/local/share/luarocks/share/lua/5.1/?.lua;/opt/local/share/luarocks/share/lua/5.1/?/init.lua'
set -x LUA_CPATH '/opt/local/lib/lua/5.1/?.so;/opt/local/lib/lua/5.1/loadall.so;./?.so;~/.luarocks/lib/lua/5.1/?.so;/opt/local/share/luarocks/lib/lua/5.1/?.so'

fish_add_path /opt/local/bin /usr/local/bin /opt/homebrew/bin
fish_add_path ~/.npm-global/bin "$PYENV_ROOT/bin" ~/projects/c/terminal_blocks
fish_add_path ~/google-cloud-sdk/bin ~/repos/cloud-sql-proxy/
fish_add_path -p "$N_PREFIX/bin"
fish_add_path ~/.luarocks/bin /opt/local/share/luarocks/bin

bind \cb git_fzf_branches
bind \cg git_fzf_log
bind \co git_fzf_commits
bind \cz 'fg 2>/dev/null; commandline -f repaint'

if test -e "/opt/local/share/fzf/shell/key-bindings.fish"
    source "/opt/local/share/fzf/shell/key-bindings.fish"
    fzf_key_bindings
end

if test -e "/opt/homebrew/opt/fzf/shell/key-bindings.fish"
    source "/opt/homebrew/opt/fzf/shell/key-bindings.fish"
    fzf_key_bindings
end

if test -e "~/.work-config.fish"
    source ~/.work-config.fish
end
