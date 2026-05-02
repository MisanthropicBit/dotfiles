return {
    src = "https://www.github.com/gbprod/substitute.nvim",
    data = {
        config = function(substitute)
            local map = require("config.map")
            local exchange = require("substitute.exchange")

            substitute.setup()

            map.n("gy", substitute.operator)
            map.n("gyy", substitute.line)
            map.n("gY", substitute.eol)
            map.x("gy", substitute.visual)

            map.n("gh", substitute.operator)
            map.n("ghh", substitute.line)
            map.n("gH", substitute.eol)
            map.x("gh", substitute.visual)

            map.n("cx", exchange.operator)
            map.n("cxx", exchange.line)
            map.n("cxc", exchange.cancel)
            map.x("X", exchange.visual)
        end,
    },
}
