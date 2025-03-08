function fish_user_key_bindings
  fzf_key_bindings

  bind \cb git_fzf_branches
  bind \cg git_fzf_log
  bind \co git_fzf_commits
  bind \cz 'fg 2>/dev/null; commandline -f repaint'
  bind \cs clear-screen
  bind \cl forward-word
  bind \ch backward-word
  bind \c_ edit_command_buffer

  # TODO: Add binding for ctrl+space with a function that removes the first token
end
