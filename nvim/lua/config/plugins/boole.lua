return {
    "nat-418/boole.nvim",
    opts = {
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
        },
    },
}
