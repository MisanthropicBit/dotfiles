#!/usr/bin/env bash

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

for e in ".vim"; do
    __symlink_install $e $script_dir $HOME
done

# Update .vim/bundle submodules
git submodule update --init
