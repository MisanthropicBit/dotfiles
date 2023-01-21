-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map = require('mappings')
local icons = require('icons')

-- bufferline.nvim {{{
---@diagnostic disable-next-line:unused-local
local function diagnostics_indicator(count, level, diagnostics_dict, context)
  local s = ' '

  for e, n in pairs(diagnostics_dict) do
    local sym = e == 'error' and icons.diagnostics.error or (e == 'warning' and icons.diagnostics.warning or icons.diagnostics.info)

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
    max_name_length = 25,
  }
}

map.set('n', 'gb', '<cmd>BufferLinePick<cr>', { desc = 'Interactively pick a tab' })
-- }}}

-- nvim-treesitter {{{
require('nvim-treesitter.configs').setup{
    ensure_installed = {
        'cpp',
        'fish',
        'javascript',
        'json',
        'python',
        'typescript',
        'vim',
        'lua',
    },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<cr>',
            node_incremental = '<cr>',
            scope_incremental = '<s-cr>',
            node_decremental = '<bs>',
        }
    },
}
-- }}}

-- nvim-treesitter-playground {{{
local has_nvim_treesitter_playground = pcall(require, 'nvim-treesitter-playground')

if has_nvim_treesitter_playground then
    map.set('n', '<localleader>sg', '<cmd>TSHighlightCapturesUnderCursor<cr>', { desc = 'Highlight treesitter or syntax group under cursor' })
end
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
        ['<c-j>'] = cmp.mapping.select_next_item(),
        ['<c-k>'] = cmp.mapping.select_prev_item(),
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'ultisnips' },
        { name = 'buffer' },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
            local text_kind = vim_item.kind
            vim_item.kind = ' ' .. (kind_icons[vim_item.kind] or '')

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

-- local function inverse_hl(name, fg_color)
--     local color = vim.api.nvim_get_hl_by_name(name, true)

--     if color ~= nil then
--         vim.api.nvim_set_hl(0, name, { fg = fg_color or color.background or 'black', bg = color.foreground })
--     end
-- end

-- function inverse_cmp_item_kinds()
--     inverse_hl('CmpItemKindFunction')
-- end

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
require('trouble').setup({
    mode = 'document_diagnostics'
})

map.set('n', '<localleader>xx', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Toggle document diagnostics in trouble' })
map.set('n', '<localleader>xl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Toggle loclist diagnostics in trouble' })
-- }}}

-- lspsaga {{{
local has_lspsaga, lspsaga = pcall(require, 'lspsaga')

if has_lspsaga then
    lspsaga.setup({
        max_preview_lines = 20,
        finder = {
            split = 's',
            vsplit = 'v',
        },
        definition = {
            split = '<c-w>s',
            vsplit = '<c-w>v',
            tabe = '<c-w>t',
        },
        symbol_in_winbar = {
            separator = '  ',
        }
    })

    local lspsaga_diagnostic = require('lspsaga.diagnostic')
    local goto_prev_error = function() lspsaga_diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end
    local goto_next_error = function() lspsaga_diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end

    -- Overwrite lsp defaults with lspsaga
    map.set('n', '<localleader>ll', '<cmd>Lspsaga show_line_diagnostics<cr>', { desc = 'Show line diagnostics' })
    map.set('n', '<localleader>la', '<cmd>Lspsaga code_action<cr>', { desc = 'Open code action menu' })
    map.set('v', '<localleader>la', '<cmd>Lspsaga code_action<cr>', { desc = 'Open code action menu in visual mode' })
    map.set('n', '<localleader>lp', '<cmd>Lspsaga diagnostic_jump_prev<cr>', { desc = 'Jump to previous diagnostic' })
    map.set('n', '<localleader>ln', '<cmd>Lspsaga diagnostic_jump_next<cr>', { desc = 'Jump to next diagnostic' })
    map.set('n', '<localleader>ep', goto_prev_error, { desc = 'Jump to previous diagnostic error' })
    map.set('n', '<localleader>en', goto_next_error, { desc = 'Jump to next diagnostic error' })
    map.set('n', '<localleader>lm', '<cmd>Lspsaga rename<cr>', { desc = 'Rename under cursor' })
    map.set('n', '<localleader>ly', '<cmd>Lspsaga outline<cr>', { desc = 'Toggle outline of semantic elements' })
    map.set('n', '<localleader>ls', '<cmd>Lspsaga lsp_finder<cr>', { desc = 'Trigger the lspsaga finder' })
end
-- }}}

-- neotest {{{
vim.diagnostic.config({}, vim.api.nvim_create_namespace('neotest'))

local neotest = require('neotest')

neotest.setup{
    icons = {
        running = icons.test.running,
        running_animated = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'},
        passed = icons.test.passed,
        failed = icons.test.failed,
        skipped = icons.test.skipped,
        unknown = icons.test.unknown,
    },
    ---@diagnostic disable-next-line:unused-local
    filter_dir = function(name, rel_path, root)
        return name ~= 'node_modules' and name ~= 'build'
    end,
    adapters = {
        require('neotest-jest')({
            jestCommand = 'npm test --',
            jestConfigFile = 'jest.config.ts',
            cwd = vim.fn.getcwd,
        }),
        require('neotest-plenary')
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

-- nvim-dap {{{
local dap = require('dap')
local dap_widgets = require('dap.ui.widgets')

map.set('n', '<localleader>db', dap.toggle_breakpoint, { desc = 'Toggle a breakpoint' })
map.set('n', '<localleader>dc', dap.continue, { desc = 'Continue debugging' })
map.set('n', '<localleader>do', dap.step_over, { desc = 'Step over' })
map.set('n', '<localleader>di', dap.step_into, { desc = 'Step into' })
map.set('n', '<localleader>du', dap.step_out, { desc = 'Step out of' })
map.set('n', '<localleader>dr', dap.repl.open, { desc = 'Open the REPL for debugging' })
map.set('n', '<localleader>dd', dap_widgets.hover, { desc = 'Inspect value of expression under cursor when debugging' })
map.set('n', '<localleader>dt', dap.terminate, { desc = 'Terminate/stop debugging' })

require('dap-vscode-js').setup({
    debugger_path = vim.fn.expand('~/vscode-js-debug'),
    -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
    log_file_path = '(stdpath cache)/dap_vscode_js.log',
    log_file_level = false,
    log_console_level = vim.log.levels.ERROR,
})

for _, language in ipairs({ 'typescript', 'javascript' }) do
    dap.adapters[language] = {
        type = 'executable',
        command = 'npm run start-env',
        options = {
            env = { LOG_LEVEL = 'WARNING' }
        }
    }

    dap.configurations[language] = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
        },
        {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
        }
    }
end

local debugging = icons.debugging
vim.fn.sign_define('DapBreakpoint', { text = debugging.breakpoint })
vim.fn.sign_define('DapBreakpointCondition', { text = debugging.breakpoint_condition })
vim.fn.sign_define('DapLogPoint', { text = debugging.log_point })
vim.fn.sign_define('DapStopped', { text = debugging.cursor, texthl = 'ErrorMsg', culhl = 'ErrorMsg' })
vim.fn.sign_define('DapBreakpointRejected', { text = debugging.rejected })
-- }}}

-- null-ls.nvim {{{
local null_ls = require('null-ls')

null_ls.setup{
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.eslint_d.with({
            condition = function(utils)
                return utils.root_has_file({ '.eslintrc' })
            end
        }),
    }
}
-- }}}


    }
-- }}}

-- ts-node-action {{{
local ts_node_action = require('ts-node-action')

ts_node_action.setup{
    typescript = require('ts-node-action.filetypes.javascript')
}

map.set('n', 'gn', ts_node_action.node_action, { desc = 'Trigger node action' })
-- }}}

-- dashboard-nvim {{{
local dashboard = require('dashboard')

--- Get a random quote from vim-starify if installed
---@return string
local function random_quote()
    if vim.g.loaded_startify == 1 then
        return vim.fn['startify#fortune#quote']()
    end

    return { '' }
end

--- Right-pad string
local function rpad(value, size, padchar)
    local npad = size - #value

    return value .. string.rep(padchar, npad)
end

local dashboard_option_width = 40

dashboard.custom_header = {
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
}

dashboard.custom_footer = random_quote
dashboard.header_pad = 6
dashboard.center_pad = 6
dashboard.footer_pad = 6
-- dashboard.preview_command = display_image_cmd()
-- dashboard.custom_header = nil
dashboard.custom_center = {
    {
        icon = 'ﱐ  ',
        desc = rpad('New file', dashboard_option_width, ' '),
        shortcut = 'i'
    },
    {
        icon = '  ',
        desc = rpad('Recently opened files', dashboard_option_width, ' '),
        shortcut = 'r'
    },
    {
        icon = '  ',
        desc = rpad('Git files', dashboard_option_width, ' '),
        action = 'GitFiles',
        shortcut = 'g'
    },
    {
        icon = '  ',
        desc = rpad('Find File', dashboard_option_width, ' '),
        action = 'Files',
        shortcut = 'f'
    },
    {
        icon = '  ',
        desc = rpad('Plugins', dashboard_option_width,  ' '),
        shortcut = 'p'
    },
    {
        icon = '  ',
        desc = rpad('Dotfiles', dashboard_option_width, ' '),
        action = '',
        shortcut = 'd'
    },
    {
        icon = '  ',
        desc = rpad('Quit', dashboard_option_width, ' '),
        action = 'q',
        shortcut = 'q'
    }
}

-- dashboard-nvim does not override keymappings (shortcuts are more like hints,
-- not actual keymaps) so set up buffer-local nowait mappings
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dashboard',
    callback = function(args)
        local map_args = { buffer = args.buf, nowait = true }

        map.set('n', 'i', '<cmd>new | startinsert<cr>', map_args)
        map.set('n', 'r', '<cmd>History<cr>', map_args)
        map.set('n', 'g', '<cmd>GitFiles<cr>', map_args)
        map.set('n', 'f', '<cmd>Files<cr>', map_args)
        map.set('n', 'p', '<cmd>PlugStatus<cr>', map_args)
        map.set('n', 'd', '<cmd>Dotfiles<cr>', map_args)
        map.set('n', 'q', '<cmd>q<cr>', map_args)
    end,
    once = true,
})
-- }}}

pcall(require, 'private_plugins')
