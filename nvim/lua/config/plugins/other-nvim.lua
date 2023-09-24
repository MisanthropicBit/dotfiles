local map = require("config.map")

local sharedJsTsTestTargets = {
    {
        target = "%1/%2.js",
        context = "js main file",
    },
    {
        target = "%1/%2.ts",
        context = "ts main file",
    }
}

require("other-nvim").setup({
    rememberBuffers = false,
    mappings = {
        {
            -- Javascript main file => test files
            pattern = "(.*)/([^.]+).js$",
            target = {
                {
                    target = "%1/%2.test.js",
                    context = "js test",
                },
                {
                    target = "%1/%2.it.js",
                    context = "js integration test",
                },
                {
                    target = "%1/%2.test.ts",
                    context = "ts test",
                },
                {
                    target = "%1/%2.it.ts",
                    context = "ts integration test",
                },
            },
        },
        {
            -- Typescript main file => test files
            pattern = "(.*)/([^.]+).ts$",
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
                {
                    target = "%1/%2.test.js",
                    context = "js test",
                },
                {
                    target = "%1/%2.it.js",
                    context = "js integration test",
                },
                {
                    target = "%1/%2.it.test.js",
                    context = "js integration test (backend)",
                },
            },
        },
        {
            -- Javascript test file => main file
            pattern = "(.*)/(.*).test.js$",
            target = sharedJsTsTestTargets,
        },
        {
            -- Javascript integration test file => main file
            pattern = "(.*)/(.*).it.js$",
            target = sharedJsTsTestTargets,
        },
        {
            -- Typescript test file => main file
            pattern = "(.*)/(.*).test.ts$",
            target = sharedJsTsTestTargets,
        },
        {
            -- Typescript integration test file => main file
            pattern = "(.*)/(.*).it.ts$",
            target = sharedJsTsTestTargets,
        },
        {
            -- Typescript integration test file (backend) => main file
            pattern = "(.*)/(.*).it.test.ts$",
            target = sharedJsTsTestTargets,
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
