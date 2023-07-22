local icons = require('icons')

local has_ts_utils, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

local function get_enclosing_function_node(node)
    while node ~= nil do
        if node:type() == 'function_declaration' then
            break
        end

        node = node:parent()
    end

    return node
end

function _G.custom_fold_text()
    local line = vim.fn.trim(vim.fn.getline(vim.v.foldstart))
    local lines_count = vim.v.foldend - vim.v.foldstart + 1
    local format = '%s%s %d lines: %s '
    local level = icons.folds.char:rep(vim.fn.foldlevel(vim.v.foldstart))

    if has_ts_utils then
        local enclosing_function_node = get_enclosing_function_node(ts_utils.get_node_at_cursor())

        if enclosing_function_node ~= nil then
            local lnum = enclosing_function_node:start()
            vim.print(lnum)

            line = 'Body of ' .. vim.fn.getline(lnum + 1)
        end
    end

    return format:format(icons.folds.marker .. '  ', level, lines_count, line)
end

vim.opt.fillchars = { fold = icons.folds.char }
vim.o.foldtext = 'v:lua.custom_fold_text()'
