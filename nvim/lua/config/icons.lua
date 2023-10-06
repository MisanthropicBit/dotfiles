local icons = {
    animation = {
        updating = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'},
    },
    color = {
        scheme = '',
    },
    debugging = {
        breakpoint = '',
        breakpoint_condition = '',
        log_point = '',
        cursor = '󰛂',
        rejected = '󰂭',
    },
    diagnostics = {
        error = ' ',
        warn = ' ',
        info = ' ',
        hint = ' ',
    },
    folds = {
        marker = '',
        char = '─',
    },
    lsp = {
        buffer = ' ',
        nvim_lsp = ' ',
        latex_symbols = 'ex',
        path = '󰙅 ',
        ultisnips = '󰁨 ',
        cmdline = '󰨊 ',
    },
    test = {
        running = '●',
        passed = '',
        failed = '',
        skipped = '',
        unknown = '?',
    },
    git = {
        logo = '󰊢',
        added = ' ',
        modified = ' ',
        removed = ' ',
    },
    files = {
        files = '󰈢',
        new = '󰝒',
        readonly = '',
    },
    misc = {
        clock = '',
        config = '',
        doctor = '',
        exit = '󰩈',
        help = '󰋗',
        package = '',
        search = '',
        search_files = '󰱼',
        update = '',
        prompt = '❯',
    },
    lines = {
        vertical = '┃',
        double_vertical = '║',
    },
    text = {
        linebreak = "↪ ",
    },
}

icons.text.bullet = icons.test.running

return icons
