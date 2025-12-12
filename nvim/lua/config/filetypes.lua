vim.filetype.add({
    extension = {
        fsproj = "xml",
        scons = "python",
        hbs = "html",
        plist = "xml",
        snap = "javascript",
    },
    filename = {
        [".eslintrc"] = "json",
        [".busted*"] = "lua",
        [".env.*"] = "sh",
    },
    pattern = {
        ["Dockerfile.*"] = "dockerfile",
        [".*gitconfig"] = "gitconfig",
        ["*.fsproj"] = "xml",
    },
})
