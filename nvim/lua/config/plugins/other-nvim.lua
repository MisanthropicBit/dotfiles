local map = require("config.map")

local jsMainTarget = {
    target = "%1/%2.js",
    context = "js main file",
}

local jsTestTarget = {
    target = "%1/%2.test.js",
    context = "js test",
}

local jsIntegrationTestTarget = {
    target = "%1/%2.it.js",
    context = "js integration test",
}

local tsMainTarget = {
    target = "%1/%2.ts",
    context = "ts main file",
}

local tsTestTarget = {
    target = "%1/%2.test.ts",
    context = "ts test",
}

local tsIntegrationTestTarget = {
    target = "%1/%2.it.ts",
    context = "ts integration test",
}

local tsBackendIntegrationTestTarget = {
    target = "%1/%2.it.test.ts",
    context = "ts integration test (backend)",
}

require("other-nvim").setup({
    rememberBuffers = false,
    mappings = {
        {
            -- Javascript main file => test files
            pattern = "(.*)/([^.]+).js$",
            target = {
                jsTestTarget,
                jsIntegrationTestTarget,
                tsTestTarget,
                tsIntegrationTestTarget,
            },
        },
        {
            -- Typescript main file => test files
            pattern = "(.*)/([^.]+).ts$",
            target = {
                tsTestTarget,
                tsIntegrationTestTarget,
                tsBackendIntegrationTestTarget,
                jsTestTarget,
                jsIntegrationTestTarget,
                {
                    target = "%1/%2.it.test.js",
                    context = "js integration test (backend)",
                },
            },
        },
        {
            -- Javascript test file => main file
            pattern = "(.*)/(.*).test.js$",
            target = {
                jsMainTarget,
                tsMainTarget,
                jsIntegrationTestTarget,
                tsIntegrationTestTarget,
                tsBackendIntegrationTestTarget,
            },
        },
        {
            -- Javascript integration test file => main file
            pattern = "(.*)/(.*).it.js$",
            target = {
                jsMainTarget,
                tsMainTarget,
                jsTestTarget,
                tsTestTarget,
            },
        },
        {
            -- Typescript test file => main file
            pattern = "(.*)/(.*).test.ts$",
            target = {
                jsMainTarget,
                tsMainTarget,
                jsIntegrationTestTarget,
                tsIntegrationTestTarget,
                tsBackendIntegrationTestTarget,
            },
        },
        {
            -- Typescript integration test file => main file
            pattern = "(.*)/(.*).it.ts$",
            target = {
                jsMainTarget,
                tsMainTarget,
                jsTestTarget,
                tsTestTarget,
            },
        },
        {
            -- Typescript integration test file (backend) => main file
            pattern = "(.*)/(.*).it.test.ts$",
            target = {
                jsMainTarget,
                tsMainTarget,
                jsTestTarget,
                tsTestTarget,
            },
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
        {
            -- C/C++ header (.h) file => implementation (.c) file
            pattern = "(.*)/(.*).h",
            target = "%1/%2.c",
            context = "c/c++ implementation (.c) file",
        },
        {
            -- C/C++ header (.hpp) file => implementation (.cpp) file
            pattern = "(.*)/(.*).hpp",
            target = "%1/%2.cpp",
            context = "c/c++ implementation (.cpp) file",
        },
        {
            -- C/C++ implementation (.c) file => header (.h) file
            pattern = "(.*)/(.*).c",
            target = "%1/%2.h",
            context = "c/c++ header (.h) file",
        },
        {
            -- C/C++ implementation (.cpp) file => header (.hpp) file
            pattern = "(.*)/(.*).cpp",
            target = "%1/%2.hpp",
            context = "c/c++ header (.hpp) file",
        }
    },
})

map.leader("n", "os", "<cmd>OtherSplit<cr>", "Open other files in a split")
map.leader("n", "ov", "<cmd>OtherVSplit<cr>", "Open other files in a vertical split")
map.leader("n", "ot", "<cmd>OtherTabNew<cr>", "Open other files in a tab")
