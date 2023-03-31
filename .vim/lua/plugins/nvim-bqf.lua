local bqf = require('nvim-bqf')

bqf.setup({
    filter = {
        fzf = {
            ['ctrl-s'] = {
                description = [[Open item in a new horizontal split]],
                default = 'split'
            }
        }
    }
})
