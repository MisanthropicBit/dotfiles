local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
    }

    -- FIX:
    vim.lsp.buf.execute_command(params)
end

-- TODO:
-- keymaps = {
--     function()
--         map.n.leader("oi", "<cmd>OrganizeImports<cr>", "Organize typescript imports")
--     end
-- }

return {
    workspace_folders = {
        vim.fs.normalize("~/repos/node-backend"),
        vim.fs.normalize("~/repos/api"),
    },
    commands = {
        OrganizeImports = {
            organize_imports,
            description = "Organize, sort, and removed unused imports",
        },
    },
}
