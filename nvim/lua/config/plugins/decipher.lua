return {
    "MisanthropicBit/decipher.nvim",
    config = function()
        local decipher = require("decipher")
        local map = require("config.map")

        decipher.setup({
            active_codecs = {
                "base64",
                "base64-url",
                "url",
            },
            float = {
                padding = 1,
                enter = true,
            },
        })

        map.n("gr", function()
            decipher.decode_motion_prompt({ preview = true })
        end, "Decode an encoded text object")

        map.n("gt", function()
            decipher.encode_motion_prompt({ preview = true })
        end, "Encode a decoded text object")

        map.v("gr", function()
            decipher.decode_motion_prompt({ preview = true })
        end, "Decode an encoded visual selection")

        map.v("gt", function()
            decipher.encode_motion_prompt({ preview = true })
        end, "Encode a visual selection")
    end,
}
