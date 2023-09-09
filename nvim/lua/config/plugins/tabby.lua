local icons = require('config.icons')

local theme = {
  fill = 'TabLineFill',
  -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
  head = 'TabLine',
  current_tab = 'TabLineSel',
  tab = 'TabLine',
  win = 'TabLine',
  tail = 'TabLine',
}

local function tab_modified(tab)
    local wins = require('tabby.module.api').get_tab_wins(tab)

    for _, x in pairs(wins) do
        if vim.bo[vim.api.nvim_win_get_buf(x)].modified then
            return ''
        end
    end

    return ''
end

local function diagnostics_indicator(buf)
    local diagnostics = vim.diagnostic.get(buf)

    local count = {0, 0, 0, 0}

    for _, diagnostic in ipairs(diagnostics) do
        count[diagnostic.severity] = count[diagnostic.severity] + 1
    end

    local modified = vim.bo[buf].modified

    if count[1] > 0 then
        return modified and "" or ""
    elseif count[2] > 0 then
        return modified and "" or ""
    end

    return modified and "" or ""
end

require('tabby.tabline').set(function(line)
  return {
    {
      { icons.files.files , hl = theme.head },
      line.sep('', theme.head, theme.fill),
    },
    line.tabs().foreach(function(tab)
      local hl = tab.is_current() and theme.current_tab or theme.tab

      return {
        line.sep('', hl, theme.fill),
        tab.is_current() and '' or '󰆣',
        tab.number(),
        tab.name(),
        line.sep('', hl, theme.fill),
        hl = hl,
        margin = ' ',
      }
    end),
    -- line.spacer(),
    -- line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
    --   return {
    --     line.sep('', theme.win, theme.fill),
    --     win.is_current() and '' or '',
    --     win.buf_name(),
    --     line.sep('', theme.win, theme.fill),
    --     hl = theme.win,
    --     margin = ' ',
    --   }
    -- end),
    {
      line.sep('', theme.tail, theme.fill),
    },
    hl = theme.fill,
  }
end)
