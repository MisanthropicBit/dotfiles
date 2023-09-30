local ls = require('luasnip')
local c = ls.choice_node
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt

local fmta = ls.extend_decorator.apply(fmt, { delimiters = '<>' })

local function get_import_export_fmt_args()
    return {
        c(
            2, {
                sn(nil, { t("{ "), i(1), t(" }") }),
                sn(nil, { t("type { "), i(1), t(" }") }),
                sn(nil, { t("* as "), i(1) }),
            }
        ),
        i(1)
    }
end

return {
    s("eaf", fmta([[export async function <>(): <> {
  <>
}]], { i(1), i(2), i(3) })),
    s("et", fmt("export type {} = {}", { i(1), i(2) })),
    s("im", fmta("import <> from '<>'", get_import_export_fmt_args())),
    s("ex", fmta("export <> from '<>'", get_import_export_fmt_args()))
}
