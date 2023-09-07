local function display_image_cmd(image_path)
    if vim.env.TERM_PROGRAM ~= 'iTerm.app' then
        return ''
    end

    local escape_seq = "\x1b]1337;File=inline=%d;size=%d;width=%s;height=%s;name=%s:%s\007"
    local encoded_path = 'a2V5Ym9hcmQtZG9scGhpbi5lbmM=' -- decipher.encode('base64', image_path)
    local encoded_data = vim.fn.system('cat ../../keyboard-dolphin.enc | base64') -- decipher.encode('base64', '')
    local cmd = string.format(escape_seq, 1, 0, 'auto', 'auto', encoded_path, encoded_data)

    vim.fn.system(cmd)
end
