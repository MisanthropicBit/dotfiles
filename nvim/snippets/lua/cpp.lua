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

namespace <> {
  class <> {
      public:
          <>(<>);
          virtual ~<>();

      private:
          <>
  };
}

#endif // <>
]],
        {
            i(1),
            rep(1),
            i(2),
            i(3),
            rep(3),
            i(4),
            rep(3),
            i(5),
            rep(1),
        })
    ),
    s(
        { trig = "guard", dscr = "Empty ifndef guard" },
        fmta([[#ifndef <>
#define <>

<>

#endif // <>
]], { i(1), rep(1), i(2), rep(1) })
    ),
    s("inc", fmt('#include "{}.h"', i(1))),
    s("pi", fmt('#include "{}.hpp"', i(1))),
    s("si", fmt('#include <{}>', i(1))),
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
    s("np", t("nullptr")),
    s("rt", t("return")),
}
