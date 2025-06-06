local config = {}

local notify = require("notify")

local _config = {}
local default_path = "configs.config"

local function get_local_path_from_path(path)
    return path .. "_local"
end

---@param table1 table
---@param table2 table
---@return table
local function mergeTables(table1, table2)
    for key, value in pairs(table2) do
        if type(value) == "table" and type(table1[key]) == "table" then
            mergeTables(table1[key], table2[key])
        else
            if type(key) == "number" then
                -- Assume this is an array
                for _, item in ipairs(table2) do
                    table.insert(table1, item)
                end

                break
            else
                table1[key] = value
            end
        end
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
        return mergeTables(default_config, local_config)
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

    _config.at_work = function()
        return _config.work_wifis and hs.fnutils.contains(_config.work_wifis, hs.wifi.currentNetwork())
    end

    return user_config
end

return setmetatable(config, {
    __index = function(_, key)
        return _config[key]
    end,
    __newindex = function(_, _)
        error("Cannot mutate configuration object")
    end,
})
