vim.filetype.add({
    extension = {
        fsproj = "xml",
        scons = "python",
        hbs = "html",
        plist = "xml",
    },
    filename = {
        [".eslintrc"] = "json",
        [".busted*"] = "lua",
    },
    pattern = {
        ["Dockerfile.*"] = "dockerfile",
        [".*gitconfig"] = "gitconfig",
        ["*.fsproj"] = "xml",
    },
})
