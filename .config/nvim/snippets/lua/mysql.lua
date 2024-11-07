local ls = require('luasnip')
local i = ls.insert_node
local s = ls.snippet
local fmt = require('luasnip.extras.fmt').fmt

return {
    s("migration", fmt([[{}

EXIT -- ROLLBACK

{}
]], { i(1), i(2) })),
}
