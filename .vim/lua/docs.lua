local docs = {}

---@class FiletypeDocsUrlConfig
---@field url string?
---@field iskeyword string[]?

---@class FiletypeDocsCommandConfig
---@field command string?
---@field query string?
---@field iskeyword string[]?

---@class FiletypeDocsShellConfig
---@field shell string?
---@field iskeyword string[]?

---@class FiletypeDocsConfigCallbackConfig
---@field config_callback fun(query: string, filetype: string): FiletypeDocsConfig
---@field iskeyword string[]?

---@class FiletypeDocsCallbackConfig
---@field callback fun(query: string, filetype: string)
---@field iskeyword string[]?

---@alias FiletypeDocsConfigAlias string

---@alias FiletypeDocsConfig
--- | FiletypeDocsUrlConfig
--- | FiletypeDocsCommandConfig
--- | FiletypeDocsShellConfig
--- | FiletypeDocsConfigCallbackConfig
--- | FiletypeDocsCallbackConfig
--- | FiletypeDocsConfigAlias

---@type FiletypeDocsConfig
local fallback = {
    config_callback = function(query, filetype)
        return {
            url = string.format('https://devdocs.io/#q=%s%%%%20%s', filetype, query)
        }
    end
}

---@type table<string, FiletypeDocsConfig>
local filetype_config = {
    -- TODO: Fix cppman
    c = {
        url = 'https://duckduckgo.com/?sites=cppreference.com&q=%s&atb=v314-1&ia=web',
        iskeyword = { ':' },
    },
    cpp = {
        url = 'https://duckduckgo.com/?sites=cppreference.com&q=%s&atb=v314-1&ia=web',
        iskeyword = { ':' },
    },
    javascript = {
        url = 'https://developer.mozilla.org/en/search?topic=api&topic=js&q=%s',
    },
    js = 'javascript',
    typescript = {
        url = 'https://developer.mozilla.org/en/search?topic=api&topic=ts&q=%s',
    },
    ts = 'typescript',
    lua = {
        ---@diagnostic disable-next-line: unused-local
        config_callback = function(query, filetype)
            if query:find('n?vim') ~= nil then
                local parts = vim.fn.split(query, '\\.')

                if parts[1] == 'vim' then
                    -- The query is to vim.api, vim.lsp etc. so grab
                    -- the last part of the word, otherwise the help
                    -- lookup won't succeed
                    return {
                        command = 'help ',
                        query = parts[#parts]
                    }
                end

                return { command = 'help' }
            end

            return fallback.config_callback(query, filetype)
        end,
        iskeyword = { '.' },
    },
    vim = {
        command = 'help',
    },
}

---@param filetype string
---@return FiletypeDocsConfig
local function get_config(filetype)
    local config = filetype_config[filetype] or fallback

    if type(config) == 'string' then
        config = filetype_config[config]
    end

    return config
end

---@param query string
---@param filetype string
---@param mods string?
---@param config FiletypeDocsConfig
local function open_docs_with_config(query, filetype, mods, config)
    local command

    if config.url ~= nil then
        local url = string.format(config.url, query)
        vim.fn.system(string.format('open "%s"', url))
        return
    elseif config.shell ~= nil then
        command = string.format('!%s %s', config.shell, query)
    elseif config.command ~= nil then
        local _query = config.query or query
        command = string.format('%s %s %s', mods or '', config.command, _query)
    elseif type(config.config_callback) == 'function' then
        config = config.config_callback(query, filetype)
        open_docs_with_config(query, filetype, mods, config)
        return
    elseif type(config.callback) == 'function' then
        config.callback(query, filetype)
        return
    else
        vim.api.nvim_echo({
            { '[config]:', 'WarningMsg' },
            { string.format("Invalid format for filetype '%s'", filetype) },
        })
        return
    end

    vim.cmd('silent ' .. command)
end

---@param query string
---@param filetype string
---@param mods string?
local function open_docs(query, filetype, mods)
    open_docs_with_config(query, filetype, mods, get_config(filetype))
end

-- Open docs for a filetype with a query
---@param query string
---@param filetype string
---@param mods string?
function docs.open(query, filetype, mods)
    open_docs(query, filetype, mods)
end

-- Open docs for the word under the cursor
function docs.open_at_cursor(options)
    local filetype = vim.bo.filetype
    local config = get_config(filetype)

    if config.iskeyword ~= nil then
        vim.opt_local.iskeyword:append(config.iskeyword)
    end

    local cword = vim.fn.expand('<cword>')

    if config.iskeyword ~= nil then
        vim.opt_local.iskeyword:remove(config.iskeyword)
    end

    docs.open(cword, filetype, options.mods)
end

-- Open docs from a command invocation
---@param options table
function docs.open_docs_from_command(options)
    local fargs = options.fargs
    local filetype = fargs[2] or vim.bo.filetype

    open_docs(fargs[1], filetype, options.mods)
end

vim.api.nvim_create_user_command(
    'Docs',
    docs.open_docs_from_command,
    {
        desc = 'Query documentation',
        nargs = '+',
    }
)

vim.api.nvim_create_user_command(
    'DocsCursor',
    docs.open_at_cursor,
    {
        desc = 'Query documentation for the word under the cursor',
        nargs = '?',
    }
)

return docs
