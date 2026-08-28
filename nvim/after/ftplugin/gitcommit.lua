local map = require("config.map")

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "50"

local options = { buffer = true, expr = true }

map.i("wip", function()
    return "WIP [skip ci]"
end, options)

map.i("skci", function()
    return "[skip ci]"
end, options)

map.i("cisk", function()
    return "[ci skip]"
end, options)

map.i("icom", function()
    return "Initial commit"
end, options)

map.i("prco", function()
    return "PR comments"
end, options)

map.i("branch", function()
    return require("config.utils.git").current_branch()
end, options)

map.i("desb", function()
    local branch = require("config.utils.git").current_branch()

    if not branch or #branch == 0 then
        return ""
    end

    local parts = vim.split(branch, "/")
    local last_part = parts[#parts]
    local with_spaces = last_part:gsub("-", " ")
    local title_cased = with_spaces:sub(1, 1):upper() .. with_spaces:sub(2)

    return title_cased
end, options)
