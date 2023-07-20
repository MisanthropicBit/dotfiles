local fzf_lua_setup = {}

local ansi = require('ansi')
local map = require('mappings')
local lsp_common = require('lsp_common')

local fzf_lua = require('fzf-lua')
local actions = require('fzf-lua.actions')

-- Returns a function for selecting a specific directory and then search it afterwards
---@param directory string
---@return fun()
function fzf_lua_setup.project_files(directory)
    local file_selector = function(selector)
        return function(selected)
            selector({ cwd = selected[1] })
        end
    end

    return function()
        fzf_lua.fzf_exec(
        'fd --type directory --maxdepth 1 . ' .. directory,
        {
            cwd = directory,
            prompt = 'Search directory❯ ',
            actions = {
                ['ctrl-s'] = file_selector(fzf_lua.files),
                ['enter'] = file_selector(fzf_lua.files),
                ['ctrl-g'] = file_selector(fzf_lua.git_files),
            },
            fzf_opts = {
                ['--preview'] = vim.fn.shellescape('tree -C -L 1 {}'),
            },
        }
        )
    end
end

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
  git = {
      status = {
          actions = {
              ['ctrl-h'] = { actions.git_stage, actions.resume },
              ['ctrl-l'] = { actions.git_unstage, actions.resume },
              ['right']   = false,
              ['left']    = false,
              ['ctrl-x']  = false,
          }
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

map.n('<c-s>', fzf_lua.lsp_document_symbols, 'LSP document symbols')
map.n('<c-p>', fzf_lua.files, 'Search files in current directory')
map.leader('n', 'cc', custom_colorschemes, 'Pick a colorscheme')
map.leader('n', 'df', function() fzf_lua.files({ cwd = '~/projects/dotfiles/.vim' }) end, 'Search dotfiles')
map.leader('n', 'gf', fzf_lua.git_files, 'Search files in the current directory that are tracked by git')
map.leader('n', 'gs', fzf_lua.git_status, 'Git status')
map.leader('n', 'gh', fzf_lua.git_stash, 'Git stash')
map.leader('n', 'bp', fzf_lua.dap_breakpoints, 'List dap breakpoints')
map.leader('n', 'hl', fzf_lua.highlights)

vim.cmd('FzfLua register_ui_select')

return fzf_lua_setup
