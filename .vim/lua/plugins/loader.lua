local loader = {}

function loader.load(plugin_name)
    local plugin_exists, _ = pcall(require, plugin_name)

    if plugin_exists then
        -- If plugin exists, load the setup file
        local plugin_config = 'plugins.' .. plugin_name
        local status, maybe_error = pcall(require, plugin_config)

        if not status then
            local msg = string.format("Failed to run plugin setup for '%s': %s", plugin_name, maybe_error)
            vim.api.nvim_echo({{ msg, 'ErrorMsg' }}, true, {})
        end
    else
        local msg = string.format("Failed to load plugin '%s'", plugin_name)
        vim.api.nvim_echo({{ msg, 'ErrorMsg' }}, true, {})
    end
end

return loader
