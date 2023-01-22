local loader = {}

function loader.load(plugin_name)
    local plugin_exists, plugin = pcall(require, plugin_name)

    if plugin_exists then
        -- If plugin exists, load the setup file
        local plugin_config = 'plugins.' .. plugin_name
        pcall(require, plugin_config)
    else
        local msg = string.format("Failed to load plugin '%s'", plugin_name)
        vim.api.nvim_echo({{ msg, 'ErrorMsg' }}, true, {})
    end
end

return loader
