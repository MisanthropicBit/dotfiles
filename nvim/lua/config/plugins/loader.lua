local loader = {}

local exclude_dirs = { "init", "loader", "setup", "bufferline", "docs" }

--- Load a plugin
---@param plugin_name string
---@return boolean, any
local function load_plugin(plugin_name)
    local plugin_config = "config.plugins." .. plugin_name

    return pcall(require, plugin_config)
end

--- Load a plugin
---@param plugin_name string
function loader.load(plugin_name)
    local plugin_exists, error = pcall(require, plugin_name)

    if not plugin_exists then
        plugin_exists, error = pcall(require, plugin_name:gsub("-", "."))
    end

    if plugin_exists then
        local status, maybe_error = load_plugin(plugin_name)

        if not status then
            local msg = string.format("Failed to run plugin setup for '%s': %s", plugin_name, maybe_error)
            vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
        else
            -- Silently attempt to load a local plugin setup
            load_plugin("local." .. plugin_name)
        end
    else
        local msg = string.format("Failed to load plugin '%s' (error: %s)", plugin_name, error)
        vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
    end
end

--- Load all plugins from a path
---@param path string
function loader.load_plugins(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.api.nvim_echo({
            {
                string.format("Plugin path is not a directory: '%s'", path),
                "ErrorMsg",
            },
        }, true, {})

        return
    end

    for name, type in vim.fs.dir(path) do
        if type == "file" then
            local plugin_name = vim.fn.fnamemodify(name, ":p:t:r")

            if not vim.tbl_contains(exclude_dirs, plugin_name) then
                loader.load(plugin_name)
            end
        end
    end
end

return loader
