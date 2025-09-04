local config = require("config")

config.read_default()

require("hyper").init()
require("autoreload").init()
require("slack_status").init()
require("autolayout").init()
