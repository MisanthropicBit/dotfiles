local colorschemes = {}

---@class config.ColorschemeStats
---@field colorschemes table<string, integer>
---@field count integer

---@type config.ColorschemeStats
local colorscheme_stats = {
    colorschemes = {},
    count = 0,
}

math.randomseed(os.time())

---@alias config.WeightedChoice { [1]: string, weight: number }

---@param weighted_choices (string | config.WeightedChoice)[]
---@return config.WeightedChoice[]
local function normalize_weights(weighted_choices)
    local total_percentage_weight = 0
    local total_unweighted = 0

    for _, choice in ipairs(weighted_choices) do
        if choice.weight then
            if 0 <= choice.weight and choice.weight <= 1.0 then
                total_percentage_weight = total_percentage_weight + choice.weight
            else
                vim.notify(('Invalid weight %d for choice %s'):format(choice.weight, choice[1]), vim.log.levels.ERROR, { title = "Config" })
            end
        else
            total_unweighted = total_unweighted + 1
        end
    end

    if total_percentage_weight > 1.0 then
        vim.notify(('Total percentage weights exceed 100%% (> %d%%)'):format(total_percentage_weight * 100), vim.log.levels.ERROR, { title = "Config" })
    end

    if total_unweighted > 0 and total_percentage_weight == 1 then
        -- There are unweighted choices but all weighted choices add up to 100%
        -- so we cannot distribute any remaining weights to the unweighted choices
        vim.notify(('Total percentage weights add up to exactly 100%% but there are %d unweighted choices'):format(total_unweighted), vim.log.levels.ERROR, { title = "Config" })
    end

    -- Convert percentage weights to normalized weights, add weights to unweighted choices
    for idx, choice in ipairs(weighted_choices) do
        if choice.weight and 0 <= choice.weight and choice.weight <= 1.0 then
            choice.weight = choice.weight * #weighted_choices
        else
            ---@cast choice string
            weighted_choices[idx] = { choice, weight = (1 - total_percentage_weight) * #weighted_choices / total_unweighted }
        end
    end

    -- Sort weighted choices by descending weight (most likely first)
    table.sort(weighted_choices, function(c1, c2)
        return (c1.weight or 1) > (c2.weight or 1)
    end)

    -- Calculate choices with cumulative weighted sum
    local cumsum = 0

    for idx, choice in ipairs(weighted_choices) do
        cumsum = cumsum + choice.weight
        weighted_choices[idx].weight = cumsum
    end

    return weighted_choices
end

---@diagnostic disable-next-line:unused-local
local exclude_colorschemes = {}

---@diagnostic disable-next-line:unused-local
---@type string[]
local builtin_colorschemes = {
    "blue",
    "darkblue",
    "default",
    "delek",
    "desert",
    "elflord",
    "evening",
    "industry",
    "koehler",
    "morning",
    "murphy",
    "pablo",
    "peachpuff",
    "ron",
    "shine",
    "slate",
    "torte",
    "zellner",
}

---@type config.WeightedChoice[]
local preferred_colorschemes = normalize_weights({
    "bamboo",
    "duskfox",
    "kanagawa",
    "kanagawa-dragon",
    "tokyonight-night",
    "obscure",
    "oldworld",
    "yorumi",
    "jellybeans",
    "nightblossom",
    "nightblossom-pastel",
    "nightblossom-sakura",
    "wildberries",
    "monet",
})

---@param weighted_choices config.WeightedChoice[]
local function random_weighted_choice(weighted_choices)
    local total_weight = weighted_choices[#weighted_choices].weight
    local random = math.random() * total_weight

    for _, choice in ipairs(weighted_choices) do
        if random <= choice.weight then
            return choice[1]
        end
    end

    assert(false, "Didn't find random weighted choice")
end

-- Run this to print stats and visually verify weighted choices
---@param stats config.ColorschemeStats
function colorschemes.print_stats(stats)
    vim.print(('Colorscheme set %d times in this session'):format(stats.count))

    for name, count in pairs(stats.colorschemes) do
        vim.api.nvim_echo({ { ("  %s = %d"):format(name, count), "" } }, true, {})
    end
end

---@return string[]
function colorschemes.get_preferred_colorschemes()
    return vim.tbl_map(function(item)
        return type(item) == 'string' and item or item[1]
    end, preferred_colorschemes)
end

---@param weighted_colorschemes config.WeightedChoice[]
---@return string
function colorschemes.get_random_colorscheme(weighted_colorschemes)
    local colorscheme = random_weighted_choice(weighted_colorschemes)

    if not colorscheme_stats.colorschemes[colorscheme] then
        colorscheme_stats.colorschemes[colorscheme] = 0
    end

    colorscheme_stats.colorschemes[colorscheme] = colorscheme_stats.colorschemes[colorscheme] + 1
    colorscheme_stats.count = colorscheme_stats.count + 1

    return colorscheme
end

---@param user_colorschemes config.WeightedChoice[]?
function colorschemes.select_random_color_scheme(user_colorschemes)
    local pool = user_colorschemes or preferred_colorschemes
    local current_colorscheme = vim.g.colors_name or nil
    local colorscheme, count = nil, 0

    -- Ensures that we don't random pick the current colorscheme
    while count <= 100 do
        colorscheme = colorschemes.get_random_colorscheme(pool)

        if not current_colorscheme or colorscheme ~= current_colorscheme then
            break
        end

        count = count + 1
    end

    vim.cmd(":colorscheme " .. colorscheme)

    return colorscheme
end

vim.api.nvim_create_user_command("RandomColorscheme", function()
    local selected = colorschemes.select_random_color_scheme()
    local msg = ("Selected colorscheme '%s'"):format(selected)

    vim.notify(msg, vim.log.levels.INFO, { title = "Config" })
end, {})

vim.api.nvim_create_user_command("ColorschemeWeights", function()
    vim.api.nvim_echo({ { "Colorscheme weights", "Title" } }, true, {})

    local prev_weight = 0

    for _, colorscheme in ipairs(preferred_colorschemes) do
        local unnorm_weight = (colorscheme.weight - prev_weight) / #preferred_colorschemes

        vim.api.nvim_echo({ { ("  %s = %.2f%%"):format( colorscheme[1], unnorm_weight * 100), "" } }, true, {})

        prev_weight = colorscheme.weight
    end
end, {})

vim.api.nvim_create_user_command("ColorschemeStats", function()
    vim.api.nvim_echo({ { "Colorscheme stats", "Title" } }, true, {})

    colorschemes.print_stats(colorscheme_stats)
end, {})

return colorschemes
