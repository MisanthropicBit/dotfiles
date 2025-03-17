local config = {}

local notify = require("notify")

local _config = {}
local default_path = "~/.hammerspoon/config.json"
local default_local_path = "~/.hammerspoon/config.local.json"

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
---@return table | string
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
---@return boolean
---@return table<string, any>?
function config.read(path)
    local config_path = path or default_path

    local ok_default, config_json = pcall(read_json_file, config_path)

    if not ok_default then
        ---@cast config_json string
        notify.send(config_json)
        return false, nil
    end

    local ok_default_local, local_config_json = pcall(read_json_file, default_local_path)

    ---@cast config_json table

    if ok_default_local then
        ---@cast local_config_json table
        merge_tables(config_json, local_config_json)
    end

    _config = config_json

    return true, _config
end

-- ---@param path string?
-- ---@return boolean
-- ---@return table<string, any>
-- function config.write(path)
--     local ok, _  = pcall(hs.json.encode, path or default_path)
--
--     if not ok then
--         notify.send("Error: Failed to write config file")
--     end
-- end

function config.at_work()
    return _config.at_work or false
end

return setmetatable(config, {
    __index = function(_, key)
        return _config[key]
    end
})
