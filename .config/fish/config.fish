# Colors
set --universal fish_color_command 00c5d7 darkcyan

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
set -gx LSCOLORS gxfxxxxxBx

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

fish_add_path /opt/local/bin /usr/local/bin /opt/homebrew/bin
fish_add_path ~/.npm-global/bin "$PYENV_ROOT/bin" ~/projects/c/terminal_blocks
fish_add_path ~/google-cloud-sdk/bin ~/repos/cloud-sql-proxy/
fish_add_path -p "$N_PREFIX/bin"

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
