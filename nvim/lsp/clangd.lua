local clangd_commands = {
    "clangd",
    "clangd-mp-11",
}

local function get_clangd_command()
    if vim.fn.executable("clangd") == 1 then
        return "clangd"
    elseif vim.fn.executable("clangd-mp-11") == 1 then
        return "clangd-mp-11"
    end

    return nil
end

return {
    config = {
        cmd = { get_clangd_command() },
    }
}
