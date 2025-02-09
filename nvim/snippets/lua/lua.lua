-- TODO: Use for 'has' snippet
local function snake_to_kebab_case(args)
    if args then
        return args[1][1]:gsub("_", "-")
    end
end

local function lower(args)
    if args then
        return args[1][1]:lower()
    end
end

return {
    -- General
    s("req", fmt('local {} = require("{}")', { i(1), i(2) })),
    s("rm", fmt('local {} = require("{}.{}")', { i(1), i(2), f(lower, 1) })),
    s("pc", fmt('local ok, {} = pcall({})', { i(1), i(2) })),
    s("pr", fmt('local {}, {} = pcall(require, "{}")', { i(1), i(2), i(3) })),
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
    s("vip", fmt("vim.print(vim.inspect({}))", i(1))),
    s("has", fmt("local has_{}, {} = pcall(require, \"{}\")", { i(1), rep(1), f(snake_to_kebab_case, 1) })),
    s("ti", fmt("table.insert({}{})", { i(1), c(2, { t(""), sn(nil, { t(", {}") } ) }) })),
    s("tr", fmt("table.remove({}{})", { i(1), c(2, { t(""), t(", {}") }) })),
    s("tc", fmt("table.concat({}{})", { i(1), c(2, { t(""), t(", {}") }) })),
    s("te", fmt("vim.tbl_extend({}{})", { i(1), c(2, { t(""), t(", {}") }) })),
    s("tde", fmt("vim.tbl_deep_extend({}{})", { i(1), c(2, { t(""), t(", {}") }) })),
    s("le", fmt("vim.list_extend({}, {})", { i(1), i(2) })),
    s("ls", fmt("vim.list_slice({}, {}, {})", { i(1), i(2), i(3) })),
    s("rt", t("return")),
    s("rn", t("return nil")),
    s("rf", t("return false")),
    s("ru", t("return true")),

    -- Busted
    s("bfe", fmt([[before_each(function()
    {}
end)]], { i(1) })),
    s("afe", fmt([[after_each(function()
    {}
end)]], { i(1) })),
    s("des", fmt([[describe("{}", function()
    {}
end)]], { i(1), i(2) })),
    s("it", fmt([[it("{}", function()
    {}
end)]], { i(1), i(2) })),
    s("ita", fmt([[async.it("{}", function()
    {}
end)]], { i(1), i(2) })),
    s("as", fmt([[assert.are.same({}, {})]], { i(1), i(2) })),
    s("at", fmt([[assert.is_true({})]], { i(1) })),
    s("af", fmt([[assert.is_false({})]], { i(1) })),
    s("an", fmt([[assert.is_nil({})]], { i(1) })),

    -- Stylua
    s(
        { trig = "is", name = "Ignore Stylua" },
        fmt("-- stylua: ignore {}\n{}", { c(1, { t("start"), t("end") }), i(0) })
    ),
}
