-- Not really using vim-startify anymore but it is installed for the quotes so
-- they can be used with another dashboard plugin

vim.g.startify_disable_at_vimenter = true

vim.g.startify_custom_header_quotes = {
    {
        "The optimal allocation is one that never happens.",
        "",
        "- Joseph E. Hoag",
    },
    {
        "Design is, as always, the art of finding compromises.",
        "",
        "- Eric Lippert",
    },
    {
        'Abstract interpretation allows us to ask the question: "What information can we glean from our program before we run it, possibly sharing the answers with an interpreter or a compiler?"',
        "",
        "- Friedman and Mendhekar",
    },
    {
        "The goal of abstract interpretation is to allow the user to do program analysis with a set of values that abstract another set of values.",
        "",
        "- Friedman and Mendhekar",
    },
    {
        "The world needs creative destruction and playful failures",
        "",
        "- Justin M. Keyes",
    },
}

vim.list_extend(vim.g.startify_custom_header_quotes, vim.fn["startify#fortune#predefined_quotes"]())
