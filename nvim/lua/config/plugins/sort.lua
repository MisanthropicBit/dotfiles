return {
    "sQVe/sort.nvim", 
    config = function()
        local map = require("config.map")

        require("sort").setup()

        local function sort_check_range()
            local start, _end = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]

            if start ~= _end then
                vim.notify("Cannot use operator-pending sort over multiple lines")
                return
            end

            vim.cmd([[Sort<cr>]])
        end

        -- TODO: Keymap conflicts
        map.o('go', sort_check_range, "Sort single-line text-object")
    end,
}
