vim.filetype.add({
    extension = {
        fsproj = "xml",
        scons = "python",
        hbs = "html",
        plist = "xml",
        snap = "javascript",
        log = "log",
    },
    filename = {
        [".eslintrc"] = "json",
        [".busted*"] = "lua",
        [".env.*"] = "sh",
        ["log"] = "log", -- Matches neovim's default log file
    },
    pattern = {
        ["Dockerfile.*"] = "dockerfile",
        [".*gitconfig"] = "gitconfig",
        ["*.fsproj"] = "xml",
    },
})
