local map = require('mappings')
local smart_splits = require('smart-splits')

smart_splits.setup({
    resize_mode = {
        quit_key = 'q'
    }
})

map.n('<c-h>', smart_splits.move_cursor_left)
map.n('<c-j>', smart_splits.move_cursor_down)
map.n('<c-k>', smart_splits.move_cursor_up)
map.n('<c-l>', smart_splits.move_cursor_right)
map.leader('n', 'sh', smart_splits.swap_buf_left, { desc = 'Swap buffer left' })
map.leader('n', 'sj', smart_splits.swap_buf_down, { desc = 'Swap buffer down' })
map.leader('n', 'sk', smart_splits.swap_buf_up, { desc = 'Swap buffer up' })
map.leader('n', 'sl', smart_splits.swap_buf_right, { desc = 'Swap buffer right' })
map.leader('n', 'rs', smart_splits.start_resize_mode, { desc = 'Start window resize mode' })
