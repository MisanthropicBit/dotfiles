return {
    "gbprod/substitute.nvim",
    config = function()
        local map = require("config.map")
        local substitute = require("substitute")

        substitute.setup()

        map.n("gy", substitute.operator)
        map.n("gyy", substitute.line)
        map.n("gY", substitute.eol)
        map.x("gy", substitute.visual)

        map.n("gh", substitute.operator)
        map.n("ghh", substitute.line)
        map.n("gH", substitute.eol)
        map.x("gh", substitute.visual)

        local exchange = require("substitute.exchange")
        map.n("cx", exchange.operator)
        map.n("cxx", exchange.line)
        map.n("cxc", exchange.cancel)
        map.x("X", exchange.visual)
    end,
}
