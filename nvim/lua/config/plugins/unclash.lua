return {
    src = "https://github.com/madmaxieee/unclash.nvim",
    data = {
        config = function(unclash)
            local map = require("config.map")

            unclash.setup({
                config = {
                    action_buttons = {
                        enabled = false,
                    },
                    annotations = {
                        enabled = true,
                    },
                },
            })

            map.n.leader("uc", unclash.accept_current)
            map.n.leader("ui", unclash.accept_incoming)
            map.n.leader("ub", unclash.accept_both)
            map.n.leader("un", unclash.next_conflict)
            map.n.leader("up", unclash.prev_conflict)
            map.n.leader("uo", unclash.open_merge_editor)
        end,
    },
}
