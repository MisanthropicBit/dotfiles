# Aliases
alias bashrc='$EDITOR ~/.bashrc'
alias bashprofile='$EDITOR ~/.bash_profile'
alias profile='$EDITOR ~/.profile'

bind TAB:menu-complete

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Extract a compressed file using the appropriate tool
extract() {
    # Warn the user if a program does not exist, before using it
    safe_use_program() {
        if [[ -f "$1" && -x "$1" ]]; then
            $($1)
        fi

        printf "\033[31mError:\003[0m The executable '%s' is not installed or in the path" "$1"
    }

    if [ -z "$1" ]; then
        echo "Usage: extract <path>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    else
        if [ -f "$1" ]; then
            local target_path="$1"

            case "$1" in
                *.tar.bz2) tar xvjf "$target_path"    ;;
                *.tar.gz)  tar xvzf "$target_path"    ;;
                *.tar.xz)  tar xvJf "$target_path"    ;;
                *.lzma)    unlzma "$target_path"      ;;
                *.bz2)     bunzip2 "$target_path"     ;;
                *.rar)     unrar x -ad "$target_path" ;;
                *.gz)      gunzip "$target_path"      ;;
                *.tar)     tar xvf "$target_path"     ;;
                *.tbz2)    tar xvjf "$target_path"    ;;
                *.tgz)     tar xvzf "$target_path"    ;;
                *.zip)     unzip "$target_path"       ;;
                *.Z)       uncompress "$target_path"  ;;
                *.7z)      7z x "$target_path"        ;;
                *.xz)      unxz "$target_path"        ;;
                *.exe)     cabextract "$target_path"  ;;
                *)         echo "Error: Unknown archive file '$1'" ;;
            esac
        else
            echo "Error: File '$1' does not exist"
        fi
    fi
}
