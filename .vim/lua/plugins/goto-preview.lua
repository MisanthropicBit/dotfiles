local map = require('mappings')

local goto_preview = require('goto-preview')

goto_preview.setup{
    height = 28,
}

map.n('gp', goto_preview.goto_preview_definition, { desc = 'Preview definition under cursor' })
map.n('gi', goto_preview.goto_preview_implementation, { desc = 'Preview implementation under cursor' })
map.n('ge', goto_preview.close_all_win, { desc = 'Close all goto-preview windows' })
map.leader('n', 'gt', goto_preview.goto_preview_type_definition, { desc = 'Preview type definition under cursor' })
