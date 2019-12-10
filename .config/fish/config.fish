set --export EDITOR                 nvim
set --export GIT_EDITOR             nvim
set --export VISUAL                 nvim
set --export FISH_POWERPROMPT_THEME "random"

# Colors
set --universal fish_color_command 00c5d7 darkcyan
set -gx LSCOLORS ExfxxxxxBx

set --local script_dir (dirname (status -f))

if test -e "$script_dir/aliases.fish"
    source "$script_dir/aliases.fish"
end

# Add macports bin/ directory
set PATH /opt/local/bin $PATH

# Add pyenv to path
set --universal PYENV_ROOT "$HOME/.pyenv"
set PATH "$PYENV_ROOT/bin" $PATH

status --is-interactive; and source (pyenv init -|psub)
