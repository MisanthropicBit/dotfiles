local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

local fmta = ls.extend_decorator.apply(fmt, { delimiters = '<>' })

return {
    s("im", fmt("import {} from '{}'", { i(2), i(1) })),
    s("imt", fmt("import type {} from '{}'", { i(2), i(1) })),
    s("ea", fmt("export * as {} from '{}'", { i(2), i(1) })),
    s("ef", fmta("export { <> } from '<>'", { i(2), i(1) })),
    s("eaf", fmta([[export async function <>(): <> {
  <>
}]], { i(1), i(2), i(3) })),
    s("et", fmt("export type {} = {}", { i(1), i(2) })),
}
