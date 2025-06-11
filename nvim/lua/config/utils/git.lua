local git = {}

---@return string?
function git.current_repository()
    if vim.fn.exists("*FugitiveGitDir") then
        return vim.fn.fnamemodify(vim.fn.FugitiveGitDir(), ":p:h:h:t")
    end

    local root = vim.fs.root(0, { ".git" })

    if root then
        return vim.fn.fnamemodify(root, ":t")
    end

    return nil
end

return git
