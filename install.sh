#!/usr/bin/env bash

config_files=(
    ".gitconfig"
    ".gitignore_global"
    ".inputrc"
    ".latexmkrc"
)

config_dirs=(
    "bat"
    "bpython"
    "nvim"
)

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf "\x1b[$1m[$2]\x1b[0m $3\n"
}

ok() {
    log "32;1" "info" "$1"
}

info() {
    log "37;1" "info" "$1"
}

warn() {
    log "33;1" "warn" "$1"
}

error() {
    log "31;1" "error" "$1"
}

prompt() {
    read -p "$1" -n 1 -r
    printf "$REPLY"
}

symlink_install() {
    if [ -e "$3/$1" ]; then
        warn "$1 already exists at $3"
    else
        ln -s "$2/$1" "$3/$1"

        if [ $? == 0 ]; then
            ok "Symlinked $1"
        else
            error "Failed to symlink $1 (return code: $?)"
        fi
    fi
}

info "Symlinking from '$script_dir' into '$HOME'..."
reply="$(prompt "Is this the correct directory? ")"

if [[ ! $reply =~ ^[Yy]$ ]]; then
    exit 1
fi

printf "\n"

for file in "${config_files[@]}"; do
    symlink_install "$file" "$script_dir" "$HOME"
done

for dir in "${config_dirs[@]}"; do
    symlink_install "$dir" "$script_dir" "$HOME/.config"
done

symlink_install "fish/aliases.fish" "$script_dir" "$HOME/.config"
symlink_install "fish/config.fish" "$script_dir" "$HOME/.config"
symlink_install "fish/functions/fish_user_key_bindings.fish" "$script_dir" "$HOME/.config"

if [[ -x "brew" ]]; then
    info "Installing homebrew packages"
    brew install bat delta fd fzf lua-language-server marksman neovim ninja node ripgrep
else
    warn "Homebrew not installed, not installing packages"
fi
