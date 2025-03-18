local config = {}

local notify = require("notify")

local _config = {}
local default_path = "configs.config"

local function get_local_path_from_path(path)
    local match = path:match([[(.+)%.json]])

    if match then
        return match .. "_local"
    end

    return nil
end

---@param table1 table
---@param table2 table
---@return table
local function merge_tables(table1, table2)
    for key, value in pairs(table2) do
        table1[key] = value
    end

    return table1
end

---@param path string?
---@return table<string, any>?
function config.read(path)
    local ok_default, default_config = pcall(require, path)

    local local_path = get_local_path_from_path(path)
    local ok_local, local_config = pcall(require, local_path)

    if ok_default and ok_local then
        return merge_tables(default_config, local_config)
    elseif ok_default then
        return default_config
    elseif ok_local then
        return local_config
    end

    return {}
end

function config.read_default()
    local user_config = config.read(default_path)

    if not user_config then
        local message = ("Failed to read config '%s'"):format(default_path)

        notify.error(message)
        error(message)
    end

    _config = user_config
    _config.at_work = user_config.at_work or false

    return user_config
end

return setmetatable(config, {
    __index = function(_, key)
        return _config[key]
    end,
    __newindex = function(_, _)
        error("Cannot mutate configuration object")
    end
})
