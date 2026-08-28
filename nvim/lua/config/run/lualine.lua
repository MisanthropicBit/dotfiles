local component = require("lualine.component"):extend()
local lualine_utils = require("lualine.utils.utils")
local icons = require("config.icons")
local run = require("config.run.run")
local utils = require("config.run.utils")

local spinner_symbol
local timer
local timer_interval = 200

local default_options = {
    icons = {
        spinner = icons.animation.spinner2,
        failed = {
            icon = icons.test.failed,
            hl = "diffRemoved",
            scope = { "fg", "bg" },
        },
        success = {
            icon = icons.test.passed,
            hl = "diffAdded",
            scope = { "fg", "bg" },
        },
        running = {
            icon = icons.test.running,
            hl = "diffChanged",
            scope = { "fg", "bg" },
        },
        unknown = {
            icon = icons.test.unknown,
            hl = "Normal",
            scope = { "fg", "bg" },
        },
    },
}

-- ---@type table<string, string[]>
-- local task_highlights = {
--     Failed = { "diffRemoved", "@diff.minus", "DiffDelete" },
--     Success = { "diffAdded", "@diff.plus", "DiffAdd" },
--     Running = { "diffChanged", "@diff.delta", "DiffChange" },
-- }
--
-- ---@param highlights table<string, string[]>
-- function resolve_task_icons_spec(highlights)
--     for status, _ in pairs(highlights) do
--         for _, hl in ipairs(highlights[status]) do
--             if vim.fn.hlexists(hl) == 0 then
--                 goto continue
--             end
--
--             local hl_def = vim.api.nvim_get_hl(0, { name = hl, create = false })
--             local new_hl = "RunStatus" .. status
--
--             if not hl_def.fg and not hl_def.bg then
--                 goto continue
--             elseif hl_def.fg then
--                 vim.api.nvim_set_hl(0, new_hl, { link = hl })
--             elseif hl_def.bg then
--                 highlight.create_hl_from(0, new_hl, { fg = { hl, "bg" } })
--             end
--
--             ::continue::
--         end
--     end
--
--     return {
--         Failed = { icon = icons.test.failed, hl = "RunStatusFailed", scope = { "fg", "bg" } },
--         Success = { icon = icons.test.passed, hl = "RunStatusSuccess", scope = { "fg", "bg" } },
--         Running = { icon = icons.test.running, hl = "RunStatusRunning", scope = { "fg", "bg" } },
--         Unknown = { icon = icons.test.unknown, hl = "Normal", scope = { "fg", "bg" } },
--     }
-- end

function component:init(options)
    component.super.init(self, options)

    self.options.label = self.options.label or ""

    if self.options.colored == nil then
        self.options.colored = true
    end

    self:update_colors()
end

function component:update_colors()
    self.highlight_groups = {}
    local task_icon_specs = run.get_task_icon_specs()

    for name, _ in pairs(task_icon_specs) do
        local icon_spec = task_icon_specs[name]
        local color = { fg = lualine_utils.extract_color_from_hllist(icon_spec.scope, icon_spec.hls) }

        self.highlight_groups[name] = self:create_hl(color, name)
    end
end

function component:update_status()
    local task = require("config.run.run").last_run_task()
    local parts = {}

    if self.options.label ~= "" then
        table.insert(parts, self.options.label)
    end

    if not task then
        local hl_start = self:format_hl(self.highlight_groups["Unknown"])
        table.insert(parts, ("%s%s %s"):format(hl_start, icons.test.unknown, "No last task"))

        return
    end

    if task:completed() then
        local status = "Failed"

        if task:exit_code() == 0 then
            status = "Success"
        end

        local hl_start = self:format_hl(self.highlight_groups[status])
        local formatted_duration, unit = utils.format_duration(task:duration())
        local task_icon_specs = run.get_task_icon_specs()

        table.insert(
            parts,
            ("%s%s %s (%d, %.2f%s)"):format(
                hl_start,
                task_icon_specs[status].icon,
                utils.format_command(task:command()),
                task:exit_code(),
                formatted_duration,
                unit
            )
        )
    elseif task:running() then
        if not timer then
            timer = vim.uv.new_timer()

            timer:start(timer_interval, timer_interval, function()
                if not task:completed() then
                    local spinner = icons.animation.spinner1
                    spinner_symbol = spinner[math.floor(vim.uv.hrtime() / (1e6 * timer_interval)) % #spinner + 1]
                    require('lualine').refresh()
                    return
                end

                timer:stop()
                timer = nil
                require('lualine').refresh()
            end)
        end

        local hl_start = self:format_hl(self.highlight_groups["Running"])

        table.insert(
            parts,
            ("%s%s %s"):format(hl_start, spinner_symbol, utils.format_command(task:command()))
        )
    end

    if #parts > 0 then
        return table.concat(parts, " ")
    end
end

return component
