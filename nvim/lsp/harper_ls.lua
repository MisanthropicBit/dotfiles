return {
    condition = function()
        return vim.fn.executable("harper-ls") == 1
    end,
}
