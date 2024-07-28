local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

return {
    s("link", fmt("[{}]({})", { i(1), i(2) })),
    s("image", fmt("![{}]({})", { i(1), i(2) })),
    s("code", fmt([[```{}
    {}
```]], { i(1), i(2) })),
}
