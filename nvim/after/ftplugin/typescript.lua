vim.opt_local.shiftwidth = 2

vim.b.run = {
    "npm run test",
    "npm run cov",
    "npm run build",
    "npm run build:js",
    "npm run build:types",
    "npm run lint",
    "npm run lint:fix",
    "npm run ci-tsc",
    "npm run ci-jest",
    "npm run ci-audit",
    "npm run ci-eslint",
    "npm run ci-auto",
}

vim.opt_local.makeprg = "npm run build"
