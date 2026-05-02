local installer = {}

---@class config.PluginHook
---@field events ("install" | "update" | "delete")[]?
---@field hook   string | string[] | function

---@class config.PluginSpec : vim.pack.Spec
---@field on     config.PluginHook?
---@field noload boolean?

local plugin_count = 0
local loadtime = 0
local _plugin_directory = "config.plugins."

---@return integer
function installer.plugin_count()
    return plugin_count
end

---@return number
function installer.loadtime()
    return loadtime
end

---@param name string
---@param value string | string[] | function
local function run_hook(name, value)
    if type(value) == "string" then
        if vim.startswith(value, ":") then
            vim.cmd(value)
        end
    elseif vim.islist(value) then
        ---@cast value string[]
        vim.system(value, function(result)
            if result.code ~= 0 then
                vim.notify(
                    ("Hook failed for plugin %s with code %d: %s"):format(
                        name,
                        result.code,
                        result.stdout or result.stderr
                    )
                )
            end
        end)
    else
        value()
    end
end

---@param spec string | config.PluginSpec
---@return boolean
local function is_vim_plugin(spec)
    local src = type(spec) == "string" and spec or spec.src

    return src:match("%/vim-.+$") ~= nil or src:match("%.vim$") ~= nil
end

---@param name string
---@param spec string | config.PluginSpec
local function install(name, spec)
    local vim_plugin = is_vim_plugin(spec)
    local config = type(spec) ~= "string" and (spec.data and spec.data.config) or {}

    -- Setup plugin configuration
    if vim_plugin then
        if vim.is_callable(config) then
            ---@cast config -nil
            config()
        end
    else
        if not spec.noload then
            -- FIX:
            local plugin = require(name ~= "mini-move" and name or "mini.move")

            if vim.is_callable(config) then
                config(plugin)
            elseif type(config) == "table" then
                if vim.is_callable(plugin.setup) then
                    plugin.setup(config)
                end
            else
                error("Expected plugin config to be a table or a function")
            end
        end
    end

    -- Setup hooks
    if spec.on ~= nil then
        if not spec.on.events then
            spec.on.events = { "install", "update" }
        end

        vim.api.nvim_create_autocmd("PackChanged", {
            callback = function(event)
                if event.data.spec.name == spec.name then
                    if vim.list_contains(spec.on.events, event.data.kind) then
                        run_hook(name, spec.on.hook)
                    end
                end
            end,
        })
    end

    plugin_count = plugin_count + 1
end

---@param name_with_ext string
---@param _type string
---@return boolean
local function should_skip_install(name_with_ext, _type)
    return name_with_ext == "init.lua"
        or _type ~= "file"
        or vim.fs.ext(name_with_ext) ~= "lua"
        or vim.startswith(name_with_ext, "_")
end

---@param options vim.pack.keyset.add?
function installer.install(options)
    local start_time = vim.uv.hrtime()
    local script_dir = vim.fs.dirname(debug.getinfo(2, "S").source:sub(2))
    local dir_iter = vim.fs.dir(script_dir, { depth = 1, follow = false })
    local names = {}
    local specs = {}

    for name_with_ext, _type in dir_iter do
        if not should_skip_install(name_with_ext, _type) then
            local name = name_with_ext:sub(1, -5)
            local spec = require(_plugin_directory .. name)

            table.insert(specs, spec)
            table.insert(names, name)
        end
    end

    -- TODO: Is plugin active before and after a restart?
    vim.pack.add(specs, options)

    for idx = 1, #specs do
        local name = names[idx]
        local spec = specs[idx]
        local ok, err = pcall(install, name, spec)

        if not ok then
            vim.notify(("Install failed for plugin '%s': %s"):format(name, err))
        end
    end

    loadtime = loadtime + (vim.uv.hrtime() - start_time) / 1e6
end

require("config.installer.commands")

return installer
