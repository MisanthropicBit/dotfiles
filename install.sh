#!/usr/bin/env bash

files=".agignore .aliases .bashrc .config .gitconfig .inputrc .latexmkrc .profile .vimrc .vim"

# Check for pre-exisiting files
for file in $files; do
    if -e "~/.$file"; then
        printf "File '.$file' already exists in your home directory, aborting...\n"
        exit 1
    fi
done

# Symlink files into user home directory
for file in $files; do
    printf "Symlinking '.$file'...\n"
    ln -s ".$file" "~/.$file"

    if [$? -ne 0]; then
        printf "Failed to symlink '.$file'!"
    fi
done

__symlink_install() {
    if [ -e "$3/$1" ]; then
        echo "Error: Cannot symlink $1 because it already exists in $3"
    else
        ln -s "$2/$1" "$3/$1"

        if [ $? != 0 ]; then
            echo "Error: Failed to symlink $1 (return code: $?)"
        fi
    fi
}

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Symlinking files from $script_dir..."

for e in ".agignore" ".aliases" ".bashrc" ".gitconfig" ".profile" ".vimrc" ".vim"; do
    __symlink_install "$e" "$script_dir" "$HOME"
done

# Update .vim/bundle submodules
git submodule update --init
