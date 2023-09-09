return {
    s("req", fmt('local {} = require("{}")', i(1), rep(1))),
    s("lf", fmt([[local function {}({})
  {}
end]], i(1), i(2), i(3))),
    s("mod", fmt([[local {} = {}

    {}

return {}]], i(1, "M"), i(2), rep(1))),
}
