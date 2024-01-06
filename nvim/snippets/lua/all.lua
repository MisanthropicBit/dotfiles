local ls = require("luasnip")
local c = ls.choice_node
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

-- local fmta = ls.extend_decorator.apply(fmt, { delimiters = "<>" })
-- local has_todo_comments, todo_comments = pcall(require, "todo-comments")

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
        WARN = "WARN"
    }
    local aliases = {}

    for key, value in pairs(keywords) do
        if aliases[value] == nil then
            aliases[value] = {}
        end

        table.insert(aliases[value], key)
    end

    return aliases
end

local todo_alias_groups = get_todo_aliases()

local function todo_snippet(trig)
    local aliases = todo_alias_groups[trig:upper()]
    local prefix = vim.opt_local.commentstring:get() or "// %s"
    local alias_choices
    aliases = aliases or { trig:upper() }

    if #aliases == 1 then
        alias_choices = t(prefix:format(aliases[1]))
    else
        alias_choices = c(
            1,
            vim.tbl_map(function(alias)
                return i(nil, prefix:format(alias))
            end, aliases)
        )
    end

    return s(trig, fmt("{}: {}", { alias_choices, i(2) }))
end

return {
    todo_snippet("todo"),
    todo_snippet("fix"),
    todo_snippet("hack"),
    todo_snippet("warn"),
    todo_snippet("perf"),
    todo_snippet("note"),
}
