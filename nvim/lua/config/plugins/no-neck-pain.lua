require("no-neck-pain").setup({
    width = vim.go.columns * 0.7,
    buffers = {
        colors = {
            blend = -0.2,
        },
        right = {
            enabled = false,
        },
    },
    mappings = {
        enabled = true,
        toggle = "<leader>np",
        toggleLeftSide = false,
        toggleRightSide = false,
        widthUp = false,
        widthDown = false,
        scratchPad = false,
    },
})
