if type -q fzf_key_bindings
    fzf_key_bindings
end

bind ctrl-g,ctrl-g git_fzf_graph
bind ctrl-g,ctrl-p sp # [G]o to [p]roject
bind ctrl-z 'fg 2>/dev/null; commandline -f repaint'
bind ctrl-s clear-screen
bind ctrl-l forward-word
bind ctrl-h backward-word
bind ctrl-minus edit_command_buffer
bind ctrl-enter nvim_grep
