local colorschemes = {}

local stats = {
    colorschemes = {},
    count = 0,
}

math.randomseed(os.time())

local function normalize_weights(weighted_choices)
    local total_percentage_weight = 0
    local total_unweighted = 0

    for _, choice in ipairs(weighted_choices) do
        if choice.weight and 0 <= choice.weight and choice.weight <= 1.0 then
            total_percentage_weight = total_percentage_weight + choice.weight
        else
            total_unweighted = total_unweighted + 1
        end
    end

    if total_percentage_weight > 1.0 then
        error(('Total percentage weights exceed 100%% (> %d%%)'):format(total_percentage_weight * 100))
    end

    if total_unweighted > 0 and total_percentage_weight == 1 then
        -- There are unweighted choices but all weighted choices add up to 100%
        -- so there are no percentages probability of picking the unweighted choices
        error(('Total percentage weights add up to exactly 100%% but there are %d unweighted choices'):format(total_unweighted))
    end

    -- Convert percentage weights to normalized weights, add weights to unweighted choices
    for idx, choice in ipairs(weighted_choices) do
        if choice.weight and 0 <= choice.weight and choice.weight <= 1.0 then
            choice.weight = choice.weight * #weighted_choices
        else
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
local builtin_colorschemes = {
    'blue',
    'darkblue',
    'default',
    'delek',
    'desert',
    'elflord',
    'evening',
    'industry',
    'koehler',
    'morning',
    'murphy',
    'pablo',
    'peachpuff',
    'ron',
    'shine',
    'slate',
    'torte',
    'zellner',
}

-- Disable aurora until treesitter hl groups are fixed
local preferred_colorschemes = normalize_weights({
    -- aurora
    'bamboo',
    -- 'barstrata',
    { 'calvera', weight = 0.2 },
    'catppuccin',
    'catppuccin-macchiato',
    { 'duskfox', weight = 0.2 },
    'everforest',
    'kanagawa',
    { 'kanagawa-dragon', weight = 0.05 },
    { 'kimbox', weight = 0.05 },
    { 'melange', weight = 0.05 },
    { 'mellifluous', weight = 0.05 },
    { 'mellow', weight = 0.05 },
    'miasma',
    'moonfly',
    { 'moonlight', weight = 0.2 },
    'tokyodark',
    'tokyonight-moon',
    'tokyonight-night',
    'tokyonight-storm'
})

---@param weighted_choices table<string | table>
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
function colorschemes.print_stats()
    vim.print(('Colorscheme set %d times in this session'):format(stats.count))
    vim.print(stats.colorschemes)
end

function colorschemes.get_preferred_colorschemes()
    return vim.tbl_map(function(item)
        return type(item) == 'string' and item or item[1]
    end, preferred_colorschemes)
end

function colorschemes.get_random_colorscheme(weighted_colorschemes)
    local colorscheme = random_weighted_choice(weighted_colorschemes)

    if not stats.colorschemes[colorscheme] then
        stats.colorschemes[colorscheme] = 0
    end

    stats.colorschemes[colorscheme] = stats.colorschemes[colorscheme] + 1
    stats.count = stats.count + 1

    return colorscheme
end

function colorschemes.select_random_color_scheme(user_colorschemes)
    local pool = user_colorschemes or preferred_colorschemes
    local current_colorscheme = vim.g.colors_name or nil
    local colorscheme = nil

    -- Ensures that we don't random pick the current colorscheme
    while true do
        colorscheme = colorschemes.get_random_colorscheme(pool)

        if not current_colorscheme or colorscheme ~= current_colorscheme then
            break
        end
    end

    vim.cmd(':colorscheme ' .. colorscheme)

    return colorscheme
end

vim.api.nvim_create_user_command('RandomColorscheme', function()
    local selected = colorschemes.select_random_color_scheme()
    local msg = ("Selected colorscheme '%s'"):format(selected)

    vim.notify(msg, vim.log.levels.INFO)
end, {})

return colorschemes
