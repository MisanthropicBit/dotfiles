require("boole").setup({
    mappings = {
        increment = "<c-a>",
        decrement = "<c-x>",
    },
    additions = {
        { "asc", "desc" },
        { "ASC", "DESC" },
        { "negative", "positive" },
        { "public", "private", "protected" },
    },
})
