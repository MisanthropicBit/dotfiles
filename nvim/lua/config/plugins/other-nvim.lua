local map = require("config.map")

require("other-nvim").setup({
    rememberBuffers = false,
    mappings = {
        {
            -- Javascript main file => test files
            pattern = "(.*)/(.*)%.js$",
            target = {
                {
                    target = "%1/%2.test.js",
                    context = "js test",
                },
                {
                    target = "%1/%2.it.js",
                    context = "js integration test",
                },
            },
        },
        {
            -- Typescript main file => test files
            pattern = "(.*)/(.*).ts$",
            target = {
                {
                    target = "%1/%2.test.ts",
                    context = "ts test",
                },
                {
                    target = "%1/%2.it.ts",
                    context = "ts integration test",
                },
                {
                    target = "%1/%2.it.test.ts",
                    context = "ts integration test (backend)",
                },
            },
        },
        {
            -- Javascript test file => main file
            pattern = "(.*)/(.*).test.js$",
            target = "%1/%2.js",
            context = "js main file",
        },
        {
            -- Javascript integration test file => main file
            pattern = "(.*)/(.*).it.js$",
            target = "%1/%2.js",
            context = "js main file",
        },
        {
            -- Typescript test file => main file
            pattern = "(.*)/(.*).test.ts$",
            target = "%1/%2.ts",
            context = "ts main file",
        },
        {
            -- Typescript integration test file => main file
            pattern = "(.*)/(.*).it.ts$",
            target = "%1/%2.ts",
            context = "ts main file",
        },
        {
            -- Typescript integration test file (backend) => main file
            pattern = "(.*)/(.*).it.test.ts$",
            target = "%1/%2.ts",
            context = "ts main file",
        },
        {
            -- Lua main file => test file
            pattern = "(.*)/(.*)%.lua$",
            target = "%1/%2_spec.lua",
            context = "lua busted test",
        },
        {
            -- Lua busted test file => main file
            pattern = "(.*)/(.*)%_spec.lua$",
            target = "%1/%2.lua",
            context = "lua main file",
        },
    },
})

map.leader("n", "os", "<cmd>OtherSplit<cr>", "Open other files in a split")
map.leader("n", "ov", "<cmd>OtherVSplit<cr>", "Open other files in a vertical split")
map.leader("n", "ot", "<cmd>OtherTabNew<cr>", "Open other files in a tab")
