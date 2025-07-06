return {
    settings = {
        json = {
            validate = {
                enable = true,
            },
            schemas = {
                {
                    description = "NPM configuration file",
                    fileMatch = { "package.json" },
                    name = "package.json",
                    url = "https://json.schemastore.org/package.json",
                },
                {
                    description = "TypeScript compiler configuration file",
                    fileMatch = { "tsconfig*.json" },
                    name = "tsconfig.json",
                    url = "https://json.schemastore.org/tsconfig.json",
                },
                {
                    description = "ESLint configuration files",
                    fileMatch = { ".eslintrc", ".eslintrc.json", ".eslintrc.yml", ".eslintrc.yaml" },
                    name = ".eslintrc",
                    url = "https://json.schemastore.org/eslintrc.json",
                },
                {
                    description = "Babel configuration file",
                    fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                    name = "babelrc.json",
                    url = "https://json.schemastore.org/babelrc.json",
                },
            },
        },
    },
}
