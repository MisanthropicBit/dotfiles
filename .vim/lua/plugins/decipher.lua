local decipher = require('decipher')
local map = require('mappings')

decipher.setup({
    active_codecs = {
        'base64',
        'base64-url',
    },
    float = {
        padding = 1,
        enter = true,
    },
})

map.set('n', 'gr', function()
    decipher.decode_motion('base64-url', { preview = true })
end)
