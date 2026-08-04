local plugin_names = {}

vim.api.nvim_create_user_command("PackUpdate", function(args)
    plugin_names = {}

    vim.pack.update(#args.fargs > 0 and args.fargs or nil, { offline = args.bang })
end, {
    nargs = "?",
    bang = true,
    complete = function()
        if #plugin_names == 0 then
            plugin_names = vim.tbl_map(function(plugin)
                return plugin.spec.name
            end, vim.pack.get())
        end

        return plugin_names
    end,
})

vim.api.nvim_create_user_command("PackLock", function(args)
    vim.cmd(("%s split %s/nvim-pack-lock.json"):format(args.mods, vim.fn.stdpath("config")))
end, {})
