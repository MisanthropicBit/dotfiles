return {
    src = "https://www.github.com/MisanthropicBit/decipher.nvim",
    data = {
        config = function(decipher)
            local map = require("config.map")

            decipher.setup({
                float = {
                    enter = true,
                },
            })

            map.n("gr", function()
                decipher.decode_motion("base64", { preview = false })
            end, "Decode an encoded text object")

            map.n("gt", function()
                decipher.encode_motion("base64", { preview = false })
            end, "Encode a decoded text object")

            map.v("gr", function()
                decipher.decode_motion("base64", { preview = false })
            end, "Decode an encoded visual selection")

            map.v("gt", function()
                decipher.encode_motion("base64", { preview = false })
            end, "Encode a visual selection")

            map.n("gR", function()
                decipher.decode_motion(decipher.codec.base64_url)
            end, "Decode an encoded text object")

            map.n("gT", function()
                decipher.encode_motion(decipher.codec.base64_url)
            end, "Encode a decoded text object")
        end,
    },
}
