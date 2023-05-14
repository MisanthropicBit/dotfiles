local ansi = require('ansi')
local map = require('mappings')
local lsp_common = require('lsp_common')

local fzf_lua = require('fzf-lua')

--- Custom symbol formatter for fzf-lua's lsp 
---@param symbol string
---@return string
local function symbol_fmt(symbol)
    -- Fzf-lua passes the symbol wrapped in ansi escape codes if the option is
    -- set so we need to strip them before looking up the lsp kind icon
    local stripped = ansi.strip_ansi_codes(symbol)
    local icon = lsp_common.kind_icons[stripped]

    if icon ~= nil then
        local color = lsp_common.lsp_kind_to_rgb_ansi(stripped)

        if color == nil then
            -- No highlight, extract ansi sequence provided by fzf-lua
            -- NOTE: This might cause some color mismatches across the same lsp kinds
            color = symbol:match(ansi.pattern())
        end

        -- Format as '  [Constant]'
        return string.format(
            '%s%s [%s]%s',
            color,
            lsp_common.kind_icons[stripped],
            stripped,
            ansi.reset_sequence()
        )
    else
        return symbol
    end
end

fzf_lua.setup{
  winopts = {
    height = 0.75,
  },
  keymap = {
    builtin = {
      ['<c-+>'] = 'toggle-help',
      ['<c-p>'] = 'preview-page-up',
      ['<c-n>'] = 'preview-page-down',
    },
  },
  lsp = {
    git_icons = true,
    symbols = {
      symbol_fmt = symbol_fmt,
    },
  },
  fzf_opts = {
    ['--cycle'] = '',
  },
}

local function custom_colorschemes()
  local colors = nil

  if vim.fn.GetPluginColorschemes ~= nil then
    colors = vim.fn.GetPluginColorschemes(true)
  end

  fzf_lua.colorschemes({ colors = colors })
end

map.leader('n', 'ss', fzf_lua.lsp_document_symbols, { desc = 'LSP document symbols' })
map.leader('n', 'cc', custom_colorschemes, { desc = 'Pick a colorscheme' })
map.leader('n', 'df', function() fzf_lua.files({ cwd = '~/projects/dotfiles/.vim' }) end, { desc = 'Search dotfiles' })
map.n('<c-p>', fzf_lua.files, { desc = 'Search files in current directory' })
map.leader('n', 'gf', fzf_lua.git_files, { desc = 'Search files in the current directory that are tracked by git' })
map.leader('n', 'gs', fzf_lua.git_status, { desc = 'Git status' })
map.leader('n', 'gh', fzf_lua.git_stash, { desc = 'Git stash' })

vim.cmd('FzfLua register_ui_select')
