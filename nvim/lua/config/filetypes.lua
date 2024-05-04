vim.filetype.add({
    extension = {
        fsproj = "xml",
        scons = "python",
        hbs = "html",
    },
    filename = {
        [".eslintrc"] = "json",
        [".busted"] = "lua",
    },
    pattern = {
        ["Dockerfile.*"] = "dockerfile",
        [".*gitconfig"] = "gitconfig",
    },
})
