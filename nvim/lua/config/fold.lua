local icons = require("config.icons")
local ts = require("config.treesitter.utils")

local has_ts_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")

function _G.custom_fold_text()
    local line = vim.fn.trim(vim.fn.getline(vim.v.foldstart))
    local lines_count = vim.v.foldend - vim.v.foldstart + 1
    local format = "%s%s%s %d lines: %s "
    local level = icons.folds.char:rep(vim.fn.foldlevel(vim.v.foldstart))

    if has_ts_utils then
        local enclosing_function_node = ts.get_enclosing_function_node(ts_utils.get_node_at_cursor())

        if enclosing_function_node ~= nil then
            local lnum = enclosing_function_node:start()

            line = "Body of " .. vim.fn.getline(lnum + 1)
        end
    end

    local indent_level, _ = line:find("[^%s]")
    local indent = (' '):rep(indent_level - 1)

    return format:format(indent, icons.folds.marker .. '  ', level, lines_count, line)
end

vim.opt.fillchars = { fold = icons.folds.char }
vim.o.foldtext = "v:lua.custom_fold_text()"
