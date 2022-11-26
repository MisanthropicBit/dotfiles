-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map_options = require('mappings').map_options

-- {{{ lsp_lines
local lsp_lines = require('lsp_lines')

lsp_lines.setup{}
lsp_lines.toggle() -- Temporarily disable lsp_lines
-- }}}

-- bufferline.nvim {{{
local function diagnostics_indicator(count, level, diagnostics_dict, context)
  local s = ' '

  for e, n in pairs(diagnostics_dict) do
    local sym = e == 'error' and ' ' or (e == 'warning' and ' ' or ' ')

    s = s .. n .. sym
  end

  return s
end

require('bufferline').setup{
  options = {
    mode = 'tabs',
    diagnostics = 'nvim_lsp',
    color_icons = true,
    diagnostics_indicator = diagnostics_indicator,
    sort_by = 'tabs',
  }
}

vim.keymap.set('n', 'gb', '<cmd>BufferLinePick', { silent = true })
-- }}}

-- nvim-treesitter {{{
require('nvim-treesitter.configs').setup{
    ensure_installed = { 'fish', 'javascript', 'json', 'python', 'typescript', 'vim', 'lua' },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
}
-- }}}

-- nvim-cmp {{{
local kind_icons = require('lsp_common').kind_icons
local cmp = require('cmp')

cmp.setup({
    snippet = {
    expand = function(args)
        vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
    end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<c-n>'] = cmp.mapping.complete(),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'ultisnips' },
    }, {
        { name = 'buffer' },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item) 
            local text_kind = vim_item.kind
            vim_item.kind = ' ' .. kind_icons[vim_item.kind]

            local type = ({
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                latex_symbols = '[LaTeX]',
                path = '[Path]',
            })[entry.source.name]

            vim_item.menu = "    (" .. text_kind .. ')'

            if type ~= nil then
                vim_item.menu = vim_item.menu .. ' ' .. type
            end

            return vim_item
        end
    }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
    },
    mapping = {
      ['<C-j>'] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          end
        end
      },
      ['<C-k>'] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          end
        end
      },
      ['<C-e>'] = {
        c = cmp.mapping.close(),
      },
      ['<Tab>'] = cmp.config.disable
    },
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

local function inverse_hl(name, fg_color)
    local color = vim.api.nvim_get_hl_by_name(name, true)

    if color ~= nil then
        vim.api.nvim_set_hl(0, name, { fg = fg_color or color.background or 'black', bg = color.foreground })
    end
end

function inverse_cmp_item_kinds()
    inverse_hl('CmpItemKindFunction')
end

-- vim.cmd([[
--     augroup InvertCmpItemKinds
--         autocmd!
--         autocmd ColorScheme * lua inverse_cmp_item_kinds()
--     augroup END
-- ]])

-- inverse_hl('CmpItemKindFunction')

-- vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = "#EADFF0", bg = "#A377BF" })
-- }}}

-- goto_preview {{{
local goto_preview = require('goto-preview')

goto_preview.setup{}
vim.keymap.set('n', 'gp', goto_preview.goto_preview_definition, map_options)
vim.keymap.set('n', '<localleader>gt', goto_preview.goto_preview_type_definition, map_options)
vim.keymap.set('n', 'gi', goto_preview.goto_preview_implementation, map_options)
vim.keymap.set('n', 'ge', goto_preview.close_all_win, map_options)
-- }}}

-- trouble.nvim {{{
require('trouble').setup()
-- }}}

-- lspsaga {{{
local has_lspsaga, lspsaga = pcall(require, 'lspsaga')

if has_lspsaga then
    lspsaga.init_lsp_saga()

    local lspsaga_diagnostic = require('lspsaga.diagnostic')
    local goto_prev_error = function() lspsaga_diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end
    local goto_next_error = function() lspsaga_diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end

    -- Overwrite lsp defaults with lspsaga
    vim.keymap.set('n', '<localleader>ll', '<cmd>Lspsaga show_line_diagnostics<cr>', map_options)
    vim.keymap.set('n', '<localleader>la', '<cmd>Lspsaga code_action<cr>', map_options)
    vim.keymap.set('n', '<localleader>lp', '<cmd>Lspsaga diagnostic_jump_prev<cr>', map_options)
    vim.keymap.set('n', '<localleader>ln', '<cmd>Lspsaga diagnostic_jump_next<cr>', map_options)
    vim.keymap.set('n', '<localleader>ep', goto_prev_error)
    vim.keymap.set('n', '<localleader>en', goto_next_error)
    vim.keymap.set('n', '<localleader>lm', '<cmd>Lspsaga rename<cr>', map_options)
    vim.keymap.set('n', '<localleader>ly', '<cmd>LSoutlineToggle<cr>', map_options)
end
-- }}}

-- neotest {{{
vim.diagnostic.config({}, vim.api.nvim_create_namespace('neotest'))

local neotest = require('neotest')

local function get_cwd(path)
    return vim.fn.getcwd()
end

neotest.setup{
  icons = {
      running = '●',
      running_animated = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'},
      passed = '',
      failed = '',
      skipped = '➠',
      unknown = '?',
  },
  adapters = {
    require('neotest-jest')({
        jestCommand = 'npm test --runInBand --',
        jestConfigFile = 'jest.config.ts',
        cwd = get_cwd,
    }),
    require('neotest-mocha')({
        command = 'npm test --',
        cwd = get_cwd,
    }),
    require("neotest-vim-test")({}),
  }
}

vim.keymap.set('n', '<localleader>tt', neotest.run.run, map_options)
vim.keymap.set('n', '<localleader>tl', neotest.run.run_last, map_options)
vim.keymap.set('n', '<localleader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, map_options)
vim.keymap.set('n', '<localleader>ts', neotest.summary.toggle, map_options)
vim.keymap.set('n', '<localleader>tp', neotest.jump.prev, map_options)
vim.keymap.set('n', '<localleader>tn', neotest.jump.next, map_options)
vim.keymap.set('n', '<localleader>tP', function() require('neotest').jump.prev({ status = 'failed' }) end, map_options)
vim.keymap.set('n', '<localleader>tN', function() require('neotest').jump.next({ status = 'failed' }) end, map_options)
-- }}}

-- boole.nvim {{{
require('boole').setup({
    mappings = {
        increment = '<c-a>',
        decrement = '<c-x>',
    },
})
-- }}}

pcall(require, 'private_plugins')
