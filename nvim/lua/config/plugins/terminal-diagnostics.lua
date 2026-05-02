return {
    src = "https://www.github.com/MisanthropicBit/terminal-diagnostics.nvim",
    data = {
        config = function(td)
            -- local autocmds = require("config.autocmds")
            local map = require("config.map")

            td.setup()

            local function setup_mappings()
                map.n("<leader>ee", function()
                    td.api.open.open({ type = "edit" })
                end, { buffer = true })
                map.n("<leader>es", function()
                    td.api.open.open({ type = "split" })
                end, { buffer = true })
                map.n("<leader>ev", function()
                    td.api.open.open({ type = "vertical" })
                end, { buffer = true })
                map.n("<leader>et", function()
                    td.api.open.open({ type = "tab" })
                end, { buffer = true })
                map.n("<leader>ew", function()
                    td.api.open.open({ type = "preview" })
                end, { buffer = true })
                map.n("<leader>ef", function()
                    td.api.open.open({ type = "float" })
                end, { buffer = true })

                map.n("<leader>ep", function()
                    td.api.jump.jump({ wrap = true, count = -1 })
                end, { buffer = true })
                map.n("<leader>en", function()
                    td.api.jump.jump({ wrap = true, count = 1 })
                end, { buffer = true })
            end

            -- autocmds.create_config_autocmd("TermOpen", { callback = setup_mappings })

            vim.api.nvim_create_user_command("TermDiag", setup_mappings, {})
        end,
    },
}
