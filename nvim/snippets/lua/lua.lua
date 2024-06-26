-- TODO: Use for 'has' snippet
local function snake_to_kebab_case(args)
    if args then
        return args[1][1]:gsub("_", "-")
    end
end

return {
    -- General
    s("req", fmt('local {} = require("{}")', { i(1), i(2) })),
    s("pc", fmt('local ok, {} = pcall({})', { i(1), i(2) })),
    s("pr", fmt('local has_{}, {} = pcall(require, "{}")', { i(1), rep(1), i(2) })),
    s("lf", fmt([[local function {}({})
    {}
end]], { i(1), i(2), i(3) })),
    s("mf", fmt([[function {}{}{}({})
    {}
end]], {
    i(1),
    c(
        2, {
            sn(nil, { t(".") }),
            sn(nil, { t(":") }),
        }
    ),
    i(3),
    i(4),
    i(5),
})),
    s("mod", fmt([[local {} = {{}}

{}

return {}]], { i(1, "M"), i(2), rep(1) })),
    s("vp", fmt("vim.print({})", i(1))),
    s("vi", fmt("vim.inspect({})", i(1))),
    s("vpi", fmt("vim.print(vim.inspect({}))", i(1))),
    s("has", fmt("local has_{}, {} = pcall(require, \"{}\")", { i(1), rep(1), f(snake_to_kebab_case, 1) })),
    s("ti", fmt("table.insert({}, {})", { i(1), i(2)  })),

    -- Busted
    s("des", fmt([[describe("{}", function()
    {}
end)]], { i(1), i(2) })),
    s("it", fmt([[it("{}", function()
    {}
end)]], { i(1), i(2) })),
    s("ita", fmt([[async.it("{}", function()
    {}
end)]], { i(1), i(2) })),
}
