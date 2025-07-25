return {
    "tpope/vim-fugitive",
    config = function()
        local map = require("config.map")

        -- Useful git mappings based on the spf13-vim distribution
        map.n.leader("gs", "<cmd>G<cr>")
        map.n.leader("gv", "<cmd>vert G<cr>")
        map.n.leader("gd", "<cmd>Gdiffsplit<cr>")
        map.n.leader("gc", "<cmd>G commit<cr>")
        map.n.leader("gb", "<cmd>G blame<cr>")
        map.n.leader("gp", "<cmd>G push<cr>")
        map.n.leader("gw", "<cmd>Gwrite<cr>")
        map.n.leader("gu", "<cmd>GBrowse!<cr>")
        map.n.leader("ms", "<cmd>Gsplit origin/master:%<cr>")
        map.n.leader("mv", "<cmd>Gvsplit origin/master:%<cr>")
        map.n.leader("mt", "<cmd>Gtabedit origin/master:%<cr>")
        map.leader({ "v", "x" }, "gu", ":GBrowse!<cr>")

        map.n("gl", "<cmd>Term git log<cr>")
        map.n("glv", "<cmd>vert Term git log<cr>")
        map.n("glt", "<cmd>tab Term git log<cr>")

        map.c("<c-b>", "<c-r>=printf('origin/%s', FugitiveHead())<cr>", { silent = false })
    end,
}
