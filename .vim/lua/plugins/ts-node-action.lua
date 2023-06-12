local map = require('mappings')

local ts_node_action = require('ts-node-action')

ts_node_action.setup{
    typescript = require('ts-node-action.filetypes.javascript')
}

map.n('gn', ts_node_action.node_action, 'Trigger node action')
