local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

local fmta = ls.extend_decorator.apply(fmt, { delimiters = "<>" })

-- TODO: Transform nodes to strip away inheritance and use filename for class name
return {
    s(
        { trig = "cl", dscr = "Define a new class" },
        fmta([[class <> {
    public:
        <>(<>);
        virtual ~<>();

    private:
        <>
}]],
        {
            i(1),
            rep(1),
            i(2),
            rep(1),
            i(3),
        })
    ),
    s(
        { trig = "cla", dscr = "Define a new header"},
        fmta([[#ifndef <>
#define <>

class <> {
    public:
        <>(<>);
        virtual ~<>();

    private:
        <>
}
]],
        {
            i(1),
            rep(1),
            i(2),
            rep(2),
            i(3),
            rep(2),
            i(4),
        })
    ),
    s(
        { trig = "guard", dscr = "Empty ifndef guard" },
        fmta([[#ifndef <>
#define <>

#endif // <>
]], { i(1), rep(1), rep(1) })
    ),
    s("inc", fmt('#include "{}".h', i(1))),
    s("pinc", fmt('#include "{}".hpp', i(1))),
    s("sinc", fmt('#include <{}>', i(1))),
    s(
        "tc",
        fmta([[TEST_CASE(<>, <>) {
    <>
}]],
        {
            i(1),
            i(2),
            i(3),
        })
    ),
    s(
        "ns",
        fmta([[namespace <> {
    <>
}]],
        {
            i(1),
            i(2),
        })
    ),
}
