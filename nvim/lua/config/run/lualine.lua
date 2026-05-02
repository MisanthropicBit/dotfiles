local component = require("lualine.component"):extend()
local lualine_utils = require("lualine.utils.utils")
local icons = require("config.icons")
local utils = require("config.run.utils")

local default_options = {
    icons = {
        spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
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

local task_icons_spec = {
    Failed = { icon = icons.test.failed, hl = "diffRemoved", scope = { "fg", "bg" } },
    Success = { icon = icons.test.passed, hl = "diffAdded", scope = { "fg", "bg" } },
    Running = { icon = icons.test.running, hl = "diffChanged", scope = { "fg", "bg" } },
    Unknown = { icon = icons.test.unknown, hl = "Normal", scope = { "fg", "bg" } },
}

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

    for name, _ in pairs(task_icons_spec) do
        local icon_spec = task_icons_spec[name]
        local hl = icon_spec.hl
        local color = { fg = lualine_utils.extract_color_from_hllist(icon_spec.scope, { hl }) }

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
    else
        if task:completed() then
            local status = "Failed"

            if task:exit_code() == 0 then
                status = "Success"
            end

            local hl_start = self:format_hl(self.highlight_groups[status])
            local formatted_duration, unit = utils.format_duration(task:duration())

            table.insert(
                parts,
                ("%s%s %s (%d, %.2f%s)"):format(
                    hl_start,
                    task_icons_spec[status].icon,
                    utils.format_command(task:command()),
                    task:exit_code(),
                    formatted_duration,
                    unit
                )
            )
        elseif task:running() then
            -- local spinner_symbol = self.symbols.spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #self.symbols.spinner + 1]
            local hl_start = self:format_hl(self.highlight_groups["Running"])

            table.insert(
                parts,
                ("%s%s %s"):format(hl_start, task_icons_spec["Running"].icon, utils.format_command(task:command()))
            )
        end
    end

    if #parts > 0 then
        return table.concat(parts, " ")
    end
end

return component
