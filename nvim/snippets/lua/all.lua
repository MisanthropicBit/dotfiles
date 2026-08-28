local ls = require("luasnip")
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

-- local fmta = ls.extend_decorator.apply(fmt, { delimiters = "<>" })
-- local has_todo_comments, todo_comments = pcall(require, "todo-comments")

local default_comment_prefix = "// %s"

local sha_chars = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
}

---@param value   string
---@param aliases string[]
---@return string[]
local function reorder_todo_aliases(value, aliases)
    ---@type string[]
    aliases = vim.tbl_filter(function(alias)
        return alias ~= value
    end, aliases)

    table.insert(aliases, 1, value)

    return aliases
end

local function get_todo_aliases()
    -- local keywords = require("todo-comments.config").keywords
    local keywords = {
        BUG = "FIX",
        FAILED = "TEST",
        FIX = "FIX",
        FIXIT = "FIX",
        FIXME = "FIX",
        HACK = "HACK",
        IMPORTANT = "WARN",
        INFO = "NOTE",
        ISSUE = "FIX",
        NOTE = "NOTE",
        OPTIM = "PERF",
        OPTIMIZE = "PERF",
        PASSED = "TEST",
        PERF = "PERF",
        PERFORMANCE = "PERF",
        TEST = "TEST",
        TESTING = "TEST",
        TODO = "TODO",
        WARN = "WARN",
    }

    local aliases = vim.defaulttable()

    for key, value in pairs(keywords) do
        table.insert(aliases[value], key)
    end

    for key, _ in pairs(aliases) do
        aliases[key] = reorder_todo_aliases(key, aliases[key])
    end

    return aliases
end

local todo_alias_groups = get_todo_aliases()

local function todo_snippet(trig)
    local aliases = todo_alias_groups[trig:upper()]

    if not aliases then
        error(("Unknown todo snippet trigger '%s'"):format(trig))
    end

    local function generate_todo_alias_node()
        local buffer = vim.api.nvim_get_current_buf()
        local prefix = vim.bo[buffer].commentstring or default_comment_prefix

        if prefix == "//%s" then
            prefix = default_comment_prefix
        end

        local alias_choices = c(
            1,
            vim.tbl_map(function(alias)
                return t(prefix:format(alias) .. ": ")
            end, aliases)
        )

        return sn(nil, { alias_choices })
    end

    return s(trig, fmt("{}{}", { d(2, generate_todo_alias_node), i(1) }))
end

local function get_iso_datetime()
    return os.date("%Y-%m-%dT%H:%M:%SZ")
end

return {
    todo_snippet("todo"),
    todo_snippet("fix"),
    todo_snippet("hack"),
    todo_snippet("warn"),
    todo_snippet("perf"),
    todo_snippet("note"),
    s(
        { trig = "iso", dscr = "Insert the current date and time formatted as an ISO datetime string" },
        f(get_iso_datetime)
    ),
    s({
        trig = [[sha(%d+)]],
        trigEngine = "pattern",
    }, {
        ---@diagnostic disable-next-line: unused-local
        f(function(args, snip)
            local result = {}

            for _ = 1, tonumber(snip.captures[1]) do
                table.insert(result, sha_chars[math.random(1, #sha_chars)])
            end

            return table.concat(result, "")
        end, {}),
    }),
}
