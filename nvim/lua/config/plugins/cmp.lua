return {
    { "Gelio/cmp-natdat", opts = {} },
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-emoji",
    { "hrsh7th/cmp-nvim-lsp", opts = {} },
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            local icons = require("config.icons")
            local kind_icons = require("config.lsp.utils").kind_icons

            -- Set cmp higlights
            vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { link = "@DiagnosticDeprecated" })
            vim.api.nvim_set_hl(0, "CmpItemKindField", { link = "@field" })
            vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "@property" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "@text" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnum", { link = "@lsp.type.enum" })
            vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { link = "@keyword" })
            vim.api.nvim_set_hl(0, "CmpItemKindConstant", { link = "@constant" })
            vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { link = "@constructor" })
            vim.api.nvim_set_hl(0, "CmpItemKindReference", { link = "@text.reference" })
            vim.api.nvim_set_hl(0, "CmpItemKindFunction", { link = "@function" })
            vim.api.nvim_set_hl(0, "CmpItemKindStruct", { link = "@lsp.type.struct" })
            vim.api.nvim_set_hl(0, "CmpItemKindClass", { link = "@lsp.type.class" })
            vim.api.nvim_set_hl(0, "CmpItemKindModule", { link = "@namespace" })
            vim.api.nvim_set_hl(0, "CmpItemKindOperator", { link = "@operator" })
            vim.api.nvim_set_hl(0, "CmpItemKindVariable", { link = "@variable" })
            vim.api.nvim_set_hl(0, "CmpItemKindFile", { link = "@text.uri" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "@" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { link = "@" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindFolder", { link = "Directory" })
            vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "@method" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { link = "@lsp.type.enumMember" })
            vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "@lsp.type.interface" })
            -- vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
            vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { link = "@lsp.type.typeParameter" })

            local menu_hl_groups = {
                nvim_lsp = "@function",
                buffer = "@tag",
                cmdline = "@number",
                luasnip = "@keyword",
                path = "@character.special",
                natdat = "@conditional",
            }

            -- Taken from:
            -- https://www.reddit.com/r/neovim/comments/1c9q60s/tip_cmp_menu_with_rightaligned_import_location/
            local function get_lsp_completion_context(completion, source)
                local ok, source_name = pcall(function() return source.source.client.config.name end)

                if not ok then
                    return nil
                end

                if source_name == "tsserver" then
                    return completion.detail
                elseif source_name == "clangd" then
                    local doc = completion.documentation

                    if doc == nil then
                        return
                    end

                    local import_str = doc.value
                    local i, j = import_str:find("[\"<].*[\">]")

                    if i == nil then
                        return
                    end

                    return import_str:sub(i, j)
                end
            end

            -- Format autocomplete items
            local function format_entry(entry, vim_item)
                vim_item.kind = " " .. (kind_icons[vim_item.kind] or "")

                local source_type = icons.lsp[entry.source.name]

                if source_type ~= nil then
                    vim_item.menu = source_type
                end

                local cmp_ctx = get_lsp_completion_context(entry.completion_item, entry.source)

                if cmp_ctx ~= nil and cmp_ctx ~= "" then
                    if vim.startswith(cmp_ctx, "@connectedcars") then
                        cmp_ctx = table.concat(vim.list_slice(vim.split(cmp_ctx, "/", { plain = true }), 1, 2), "/")
                    end

                    vim_item.menu = vim_item.menu .. " " .. cmp_ctx
                else
                    vim_item.menu = ""
                end

                vim_item.menu = (vim_item.menu or "")
                vim_item.menu_hl_group = menu_hl_groups[entry.source.name] or ""

                return vim_item
            end

            -- Get buffers to autocomplete text from. Gets all visible buffers with a byte limit
            local function get_bufnrs()
                local function buf_bytesize(buffer)
                    return vim.api.nvim_buf_get_offset(buffer, vim.api.nvim_buf_line_count(buffer))
                end

                local max_bytesize = 1024 * 1024
                local total_bytesize = 0
                local buffers = {}

                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buffer = vim.api.nvim_win_get_buf(win)
                    local bytesize = buf_bytesize(buffer)

                    if total_bytesize + bytesize < max_bytesize then
                        table.insert(buffers, vim.api.nvim_win_get_buf(win))
                        total_bytesize = total_bytesize + bytesize
                    else
                        break
                    end
                end

                return buffers
            end

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<c-j>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<c-k>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        elseif cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end),
                    ["<c-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<c-f>"] = cmp.mapping.scroll_docs(4),
                    ["<c-e>"] = cmp.mapping.abort(),
                    ["<c-y>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    {
                        name = "buffer",
                        option = {
                            get_bufnrs = get_bufnrs,
                        },
                    },
                    { name = "natdat" },
                    { name = "emoji" },
                }),
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = format_entry,
                },
                -- TODO: Make lsp sources close to the cursor score higher
            })

            -- Use buffer source for `/` (if you enabled `native_menu`, this
            -- won't work anymore).
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            -- Use cmdline & path source for ":" (if you enabled `native_menu`,
            -- this won't work anymore).
            cmp.setup.cmdline(":", {
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                },
                mapping = {
                    ["<C-j>"] = {
                        c = function()
                            if cmp.visible() then
                                cmp.select_next_item()
                            end
                        end,
                    },
                    ["<C-k>"] = {
                        c = function()
                            if cmp.visible() then
                                cmp.select_prev_item()
                            end
                        end,
                    },
                    ["<C-e>"] = {
                        c = cmp.mapping.close(),
                    },
                    ["<Tab>"] = cmp.config.disable,
                },
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" },
                        },
                    }
                }),
            })
        end,
    },
}
