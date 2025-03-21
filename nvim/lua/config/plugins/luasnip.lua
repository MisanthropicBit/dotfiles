return {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
        local luasnip = require("luasnip")
        local loaders = require("luasnip.loaders")
        local from_lua = require("luasnip.loaders.from_lua")
        local vscode = require("luasnip.loaders.from_vscode")

        local map = require("config.map")

        local function snippets_path(...)
            local paths = { ... }

            return ("%s/%s"):format(vim.fn.stdpath("config"), table.concat(paths, "/"))
        end

        luasnip.setup({
            update_events = "TextChanged,TextChangedI",
        })

        luasnip.filetype_extend("all", { "all" })
        luasnip.filetype_extend("all", { "_" })
        luasnip.filetype_extend("javascript", { "javascript-typescript-shared" })
        luasnip.filetype_extend("typescript", { "javascript-typescript-shared" })

        vscode.lazy_load()
        from_lua.lazy_load({ paths = { snippets_path("snippets", "lua") } })

        map.set({ "i", "s" }, "<c-i>", function()
            if luasnip.expandable() then
                luasnip.expand()
            else
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<tab>", true, false, true), 'n', false)
            end
        end, "Expand snippet")

        map.set({ "i", "s" }, "<c-j>", function()
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            end
        end, "Jump to next position in a snippet")

        map.set({ "i", "s" }, "<c-k>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, "Jump to previous position in a snippet")

        map.set({ "i", "s" }, "<c-l>", function()
            if luasnip.choice_active() then
                require("luasnip.extras.select_choice")()
            end
        end, "Pick from a choice node")

        map.set({ "i", "s" }, "<c-h>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(-1)
            end
        end, "Previous snippet choice")

        map.n.leader("sf", function()
            loaders.edit_snippet_files({
                edit = function(file)
                    vim.cmd("tabe " .. file)
                end,
            })
        end)
    end,
}
