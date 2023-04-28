local loader = require('plugins.loader')

loader.load_plugins(vim.fn.stdpath('config') .. '/' .. 'lua/plugins')
