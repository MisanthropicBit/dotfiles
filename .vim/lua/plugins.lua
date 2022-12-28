-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map = require('mappings')

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

map.set('n', 'gb', '<cmd>BufferLinePick<cr>', { desc = 'Interactively pick a tab' })
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
map.set('n', 'gp', goto_preview.goto_preview_definition, { desc = 'Preview definition under cursor' })
map.set('n', '<localleader>gt', goto_preview.goto_preview_type_definition, { desc = 'Preview type definition under cursor' })
map.set('n', 'gi', goto_preview.goto_preview_implementation, { desc = 'Preview implementation under cursor' })
map.set('n', 'ge', goto_preview.close_all_win, { desc = 'Close all goto-preview windows' })
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
    map.set('n', '<localleader>ll', '<cmd>Lspsaga show_line_diagnostics<cr>', { desc = 'Show line diagnostics' })
    map.set('n', '<localleader>la', '<cmd>Lspsaga code_action<cr>', { desc = 'Open code action menu' })
    map.set('n', '<localleader>lp', '<cmd>Lspsaga diagnostic_jump_prev<cr>', { desc = 'Jump to previous diagnostic' })
    map.set('n', '<localleader>ln', '<cmd>Lspsaga diagnostic_jump_next<cr>', { desc = 'Jump to next diagnostic' })
    map.set('n', '<localleader>ep', goto_prev_error, { desc = 'Jump to previous diagnostic error' })
    map.set('n', '<localleader>en', goto_next_error, { desc = 'Jump to next diagnostic error' })
    map.set('n', '<localleader>lm', '<cmd>Lspsaga rename<cr>', { desc = 'Rename under cursor' })
    map.set('n', '<localleader>ly', '<cmd>LSoutlineToggle<cr>', { desc = 'Toggle outline of semantic elements' })
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

map.set('n', '<localleader>tt', neotest.run.run, { desc = 'Run the test under the cursor' })
map.set('n', '<localleader>tl', neotest.run.run_last, { desc = 'Run the last run test' })
map.set('n', '<localleader>tf', function() neotest.run.run(vim.fn.expand('%')) end, { desc = 'Run all tests in file' })
map.set('n', '<localleader>ts', neotest.summary.toggle, { desc = 'Toggle test summary' })
map.set('n', '<localleader>tp', neotest.jump.prev, { desc = 'Jump to previous test' })
map.set('n', '<localleader>tn', neotest.jump.next, { desc = 'Jump to next test' })
map.set('n', '<localleader>tP', function() neotest.jump.prev({ status = 'failed' }) end, { desc = 'Jump to previous failed test' })
map.set('n', '<localleader>tN', function() neotest.jump.next({ status = 'failed' }) end, { desc = 'Jump to next failed test' })
map.set('n', '<localleader>to', neotest.output.open, { desc = 'Open test output' })
map.set('n', '<localleader>tL', function() neotest.output.open({ last_run = true }) end, { desc = 'Open test output for the last run test' })
map.set('n', '<localleader>tO', neotest.output_panel.toggle, { desc = 'Toggle the test output panel' })
map.set('n', '<localleader>td', function() neotest.run.run({ strategy = 'dap' }) end, { desc = 'Run the test under the cursor using dap' })
map.set('n', '<localleader>tS', function() neotest.run.run({ suite = true }) end, { desc = 'Run entire test suite' })
-- }}}

-- boole.nvim {{{
require('boole').setup({
    mappings = {
        increment = '<c-a>',
        decrement = '<c-x>',
    },
})
-- }}}

-- lsp_signature.nvim {{{
require('lsp_signature').setup()
-- }}}

-- indent-blankline.nvim {{{
require('indent_blankline').setup({
    show_current_context = true,
    show_current_context_start = true,
    char = '',
    context_char = '│',
})
-- }}}

pcall(require, 'private_plugins')
