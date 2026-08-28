local git = {}

---@return boolean
local function has_fugitive()
    return vim.fn.exists("*FugitiveGitDir") == 1
end

---@return boolean
local function buffer_has_active_gitsigns()
    return type(vim.b.gitsigns_status_dict) == "table"
end

---@return string?
function git.current_repository()
    if has_fugitive() then
        return vim.fn.fnamemodify(vim.fn.FugitiveGitDir(), ":p:h:h:t")
    end

    local root = vim.fs.root(0, { ".git" })

    if root then
        return vim.fn.fnamemodify(root, ":t")
    end

    return nil
end

---@return string?
function git.current_branch()
    if has_fugitive() then
        return vim.fn["fugitive#Head"]()
    elseif buffer_has_active_gitsigns() then
        return vim.b.gitsigns_status_dict.head
    end
end

return git
