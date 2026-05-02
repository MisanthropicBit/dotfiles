---@type config.PluginSpec
return {
    src = "https://www.github.com/nat-418/boole.nvim",
    data = {
        config = {
            mappings = {
                increment = "<c-a>",
                decrement = "<c-x>",
            },
            additions = {
                { "asc", "desc" },
                { "ASC", "DESC" },
                { "negative", "positive" },
                { "public", "private", "protected" },
                { "const", "let" },
                { "force", "keep", "error" }, -- vim.tbl_extend behaviours
                { "continue", "break" },
                { "type", "interface" },
            }
        }
    }
}
