return {
    dir = "~/projects/nvim/terminal-diagnostics.nvim",
    config = function()
        local td = require("terminal-diagnostics")
        local autocmds = require("config.autocmds")
        local map = require("config.map")

        local function setup()
            map.n("<leader>ee", function() td.api.open.open({ type = "edit" }) end)
            map.n("<leader>es", function() td.api.open.open({ type = "split" }) end)
            map.n("<leader>ev", function() td.api.open.open({ type = "vertical" }) end)
            map.n("<leader>et", function() td.api.open.open({ type = "tab" }) end)
            map.n("<leader>ew", function() td.api.open.open({ type = "preview" }) end)
            map.n("<leader>ef", function() td.api.open.open({ type = "float" }) end)

            map.n("<leader>ep", function() td.api.jump.jump({ wrap = true, count = -1 }) end)
            map.n("<leader>en", function() td.api.jump.jump({ wrap = true, count = 1 }) end)
        end

        autocmds.create_config_autocmd("TermOpen", { callback = setup })

        vim.api.nvim_create_user_command("TermDiag", setup, {})
    end,
}
