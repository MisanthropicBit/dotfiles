set --export EDITOR                 nvim
set --export GIT_EDITOR             nvim
set --export VISUAL                 nvim
set --export FISH_POWERPROMPT_THEME "random"

# Colors
set --universal fish_color_command 00c5d7 darkcyan
set -gx LSCOLORS FxfxxxxxBx

set --local script_dir (dirname (status -f))

if test -e "$script_dir/aliases.fish"
    source "$script_dir/aliases.fish"
end

# Add macports bin/ directory
set -x PATH /opt/local/bin $PATH

set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/texlive/2019/bin/x86_64-darwin/ $PATH
set -x PATH ~/.npm-global/bin $PATH
set -x PATH /Library/Frameworks/Mono.framework/Versions/Current/bin $PATH
set -x PATH /usr/local/share/dotnet/ $PATH

# Android
set -x ANDROID_HOME $HOME/Library/Android/sdk
set -a PATH $ANDROID_HOME/emulator
set -a PATH $ANDROID_HOME/tools
set -a PATH $ANDROID_HOME/tools/bin
set -a PATH $ANDROID_HOME/platform-tools

# Opt out of Microsoft's CLI telemetry
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1

# Add pyenv to path
set --universal PYENV_ROOT "$HOME/.pyenv"
set PATH "$PYENV_ROOT/bin" $PATH

# Add terminal blocks game to path
set -a PATH ~/projects/c/terminal_blocks

# Use neovim as a pager for manpages
if type nvim &> /dev/null
    set -x MANPAGER "nvim +Man!"
end

status --is-interactive; and source (pyenv init -|psub)

set --local -a nigiri_files\
    '~/projects/fish/nigiri/fish_prompt.fish'\
    '~/projects/fish/nigiri/fish_right_prompt.fish'

for nigiri_file in $nigiri_files
    if test \( -e $nigiri_file \) -a \( -f $nigiri_file \)
        source $nigiri_file
    end
end

set -x MYSQL_PS1 "mysql v\v [\U][\d]> "
set -x BAT_THEME OneHalfDark
set -x FZF_DEFAULT_COMMAND "fd -tf --color=never"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND --search-path \$dir"
set -x FZF_CTRL_T_OPTS '--multi --bind="ctrl-s:select,ctrl-u:deselect,ctrl-f:reload(find . -type f \$dir),ctrl-d:reload(find . -type d \$dir)" --preview="bat -n --color=always {}"'
set -x FZF_ALT_C_COMMAND 'fd -td --color=never'
set -x FZF_DEFAULT_OPTS "--color='pointer:bright-blue,marker:bright-green' --height=50% --pointer='⇨ ' --marker='✓' --bind='ctrl-n:preview-page-down,ctrl-p:preview-page-up'"

bind \cb git_fzf_branches
bind \cg git_fzf_log
bind \co git_fzf_commits

if test -e "/opt/local/share/fzf/shell/key-bindings.fish"
    source "/opt/local/share/fzf/shell/key-bindings.fish"
    fzf_key_bindings
end

if test -e "~/.work-config.fish"
    source ~/.work-config.fish
end

set -x N_PREFIX ~/.n
fish_add_path -p "$N_PREFIX/bin"
