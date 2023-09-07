vim.o.formatprg = "stylua -"
vim.o.include = [==[^.*require\s*(\{0,1\}["']\zs[^"']\+\ze["']]==]
-- vim.o.includeexpr = "v:lua.require('dotfiles.lua').includeexpr(v:fname)"
