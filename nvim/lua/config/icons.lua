local icons = {
    animation = {
        updating = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    },
    color = {
        scheme = "",
    },
    debugging = {
        breakpoint = "",
        breakpoint_condition = "",
        log_point = "",
        cursor = "󰛂",
        rejected = "󰂭",
    },
    diagnostics = {
        error = " ",
        warn = " ",
        info = " ",
        hint = "󰌵 ",
    },
    folds = {
        marker = "",
        char = "─",
    },
    -- TODO: Change name to "completion" or similar
    lsp = {
        buffer = " ",
        nvim_lsp = " ",
        latex_symbols = "ex",
        path = "󰙅 ",
        ultisnips = "󰁨 ",
        cmdline = "󰨊 ",
        natdat = "",
    },
    test = {
        running = "●",
        passed = "",
        failed = "",
        skipped = "",
        unknown = "",
    },
    git = {
        logo = "󰊢",
        added = " ",
        modified = " ",
        removed = " ",
    },
    files = {
        files = "󰈢",
        new = "󰝒",
        readonly = "",
        oil = "",
    },
    misc = {
        alarm = "󰞏",
        clock = "",
        config = "",
        doctor = "",
        exit = "󰩈",
        help = "󰋗",
        package = "",
        prompt = "❯",
        search = "",
        search_files = "󰱼",
        update = "",
    },
    lines = {
        vertical = "┃",
        double_vertical = "║",
    },
    separators = {
        high_slant_lower_right = "",
        high_slant_upper_left = "",
        high_slant_lower_left = "",
        bubble_left = "",
        bubble_right = "",
    },
    text = {
        linebreak = "↪ ",
    },
}

icons.text.bullet = icons.test.running

return icons
