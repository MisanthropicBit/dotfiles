local image = {}

-- iTerm2 escape sequence for images (https://iterm2.com/documentation-images.html)
local escape_seq = "\x1b]1337;File=inline=%d;size=%d;width=%s;height=%s;name=%s:%s\007"

--- Displays an image
---@param image_path string
function image.display(image_path)
    if vim.env.TERM_PROGRAM ~= 'iTerm.app' then
        return ''
    end

    local encoded_path = 'a2V5Ym9hcmQtZG9scGhpbi5lbmM='
    local encoded_data = vim.fn.system(string.format('cat %s | base64', image_path))
    local cmd = string.format(escape_seq, 1, 0, 'auto', 'auto', encoded_path, encoded_data)

    return vim.fn.system(cmd)
end

return image
