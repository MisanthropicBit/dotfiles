vim.filetype.add({
    extension = {
        fsproj = "xml",
        scons = "python",
        hbs = "html",
    },
    filename = {
        [".eslintrc"] = "json",
    },
    pattern = {
        ["Dockerfile.*"] = "dockerfile",
        [".*gitconfig"] = "gitconfig",
    },
})
