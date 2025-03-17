local config = {}

local notify = require("notify")

local _config = {}
local default_path = os.getenv("HOME") .. "/.hammerspoon/configs/config.json"

local function get_local_path_from_path(path)
    local match = path:match([[(.+)%.json]])

    if match then
        return match .. ".local.json"
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

---@param path string
---@return table
local function read_json_file(path)
    local file = io.open(path, "r")

    if not file then
        error(("Error: Failed to read file '%s'"):format(path))
    end

    local data = file:read("*a")
    file:close()

    local ok, json = pcall(hs.json.decode, data)

    if not ok then
        error(("Error: Failed to decode config file '%s'"):format(path))
    end

    ---@cast json table

    return json
end

---@param path string?
---@return table<string, any>?
function config.read(path)
    local config_path = path or default_path
    local ok_default, config_json = pcall(read_json_file, config_path)

    local local_path = get_local_path_from_path(config_path)
    local ok_default_local, local_config_json = pcall(read_json_file, local_path)

    ---@cast config_json table

    if ok_default and ok_default_local then
        ---@cast local_config_json table
        merge_tables(config_json, local_config_json)
    elseif ok_default_local then
        config_json = local_config_json
    end

    return config_json
end

function config.read_default()
    local config_json = config.read()

    if not config_json then
        notify.error("Failed to read config")
        error("Failed to read default config")
    end

    _config = config_json
    _config.at_work = _config.at_work or false

    return _config
end

return setmetatable(config, {
    __index = function(_, key)
        return _config[key]
    end,
    __newindex = function(_, _)
        error("Cannot mutate configuration object")
    end
})
