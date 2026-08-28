---@type config.PluginSpec
return {
    src = "https://www.github.com/MisanthropicBit/terminal-diagnostics.nvim",
    version = "e0c3cd36b895dffbfb0d7add9c985ba628e5be8f",
    data = {
        config = function(td)
            local autocmds = require("config.autocmds")
            local map = require("config.map")

            td.setup()

            local function setup_mappings()
                map.n("<leader>ee", "<cmd>TermDiagOpen edit<cr>", { buffer = true })
                map.n("<leader>es", "<cmd>TermDiagOpen split<cr>", { buffer = true })
                map.n("<leader>ev", "<cmd>TermDiagOpen vertical<cr>", { buffer = true })
                map.n("<leader>et", "<cmd>TermDiagOpen tab<cr>", { buffer = true })
                map.n("<leader>ew", "<cmd>TermDiagOpen preview<cr>", { buffer = true })
                map.n("<leader>ef", "<cmd>TermDiagOpen float<cr>", { buffer = true })
                map.n("<leader>ep", "<cmd>1TermDiagPrevious!<cr>", { buffer = true })
                map.n("<leader>en", "<cmd>1TermDiagNext!<cr>", { buffer = true })
                map.n("<leader>eb", "<cmd>TermDiagSearch<cr>", { buffer = true })
            end

            autocmds.create_config_autocmd("TermOpen", { callback = setup_mappings })

            vim.api.nvim_create_user_command("TermDiagMappings", setup_mappings, {})
        end,
    },
}
