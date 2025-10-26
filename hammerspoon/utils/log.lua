local config = require("config")

return hs.logger.new("config", config.log_level or "warning")
