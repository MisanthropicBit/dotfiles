---@type config.PluginSpec
return {
    src = "https://www.github.com/nat-418/boole.nvim",
    version = "7b4a3dae28e3b2497747aa840439e9493cabdc49",
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
