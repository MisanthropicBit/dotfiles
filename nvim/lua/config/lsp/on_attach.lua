local lsp_on_attach = {}

local icons = require("config.icons")
local map = require("config.map")

-- We don't want ts_ls to format stuff as the default formatting doesn't
-- seem to respect project-local settings for eslint and prettier.
local function lsp_format_wrapper()
    vim.lsp.buf.format({
        filter = function(client)
            return client.name ~= "ts_ls"
        end,
    })
end

---Use fzf-lua as a lsp result selector in case of multiple results
---@param locations any
local function fzf_lua_lsp_jump_selector(locations)
    local fzf_items = vim.tbl_map(function(item)
        return ("%s:%d:%d"):format(item.filename, item.lnum, item.col)
    end, locations)

    require("fzf-lua").fzf_exec(fzf_items, {
        prompt = "Jump to " .. icons.misc.prompt .. " ",
        previewer = "builtin",
    })
end

---Jump to an lsp result in a split window or select between results if there
---is more than one
---@param lsp_method string
---@param split_cmd string
---@param selector "fzf" | "quickfix"
---@return function
local function lsp_request_jump(lsp_method, split_cmd, selector)
    return function()
        ---@param client vim.lsp.Client
        ---@return lsp.TextDocumentPositionParams
        local function get_params(client)
            return vim.lsp.util.make_position_params(0, client.offset_encoding)
        end

        vim.lsp.buf_request_all(0, lsp_method, get_params, function(results)
            local clients = vim.tbl_keys(results)

            if #clients == 0 then
                return
            elseif #clients == 1 then
                local client = vim.lsp.get_client_by_id(clients[1])
                ---@cast client -nil

                if results[client.id] and results[client.id].result and #results[client.id].result > 0 then
                    vim.cmd(split_cmd)
                    vim.lsp.util.show_document(results[client.id].result[1], client.offset_encoding, { focus = true })
                    vim.cmd("normal zt")
                end
            else
                local locations = {}

                for client_id, result in pairs(results) do
                    local client = vim.lsp.get_client_by_id(client_id)

                    if client then
                        local items = vim.lsp.util.locations_to_items(result.result, client.offset_encoding)

                        vim.list_extend(locations, items)
                    end
                end

                local has_fzf_lua, _ = pcall(require, "fzf-lua")

                if selector == "fzf" and has_fzf_lua then
                    fzf_lua_lsp_jump_selector(locations)
                else
                    vim.fn.setqflist({}, " ", { items = locations })
                    vim.cmd("copen")
                end
            end
        end)
    end
end

function lsp_on_attach.on_attach(event)
    -- TODO: Extend server capabilities with cmp_nvim_lsp
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
        return
    end

    local buffer = event.buf

    if client.server_capabilities.completionProvider then
        vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
    end

    local function with_desc(desc)
        return map.with_default_options({ buffer = buffer, desc = desc })
    end

    local function lsp_definition()
        vim.lsp.buf.definition()
        vim.cmd("normal zt")
    end

    -- TODO: Use on_list handler argument?
    -- We don't guard against server capabilities because we want neovim to
    -- inform us if the lsp server doesn't support a method
    map.n("gd", lsp_definition, with_desc("Jump to definition under cursor"))
    map.n("<s-m>", function()
        vim.lsp.buf.hover({ border = "rounded" })
    end, with_desc("Open lsp float"))
    map.n.leader("lc", vim.lsp.buf.declaration, with_desc("Jump to declaration under cursor"))
    map.n.leader("lt", vim.lsp.buf.type_definition, with_desc("Jump to type definition"))
    map.n.leader("lh", vim.lsp.buf.signature_help, with_desc("Lsp signature help"))
    map.n.leader("lm", vim.lsp.buf.rename, with_desc("Rename under cursor"))
    map.leader({ "n", "v" }, "lf", lsp_format_wrapper, with_desc("Format code in a buffer or in a range"))

    -- Set up document symbol and lsp references mappings if they are not already bound (by e.g. fzf-lua)
    map.n("<c-s>", vim.lsp.buf.document_symbol, { buffer = buffer, desc = "Show document symbol", check = true })

    map.n.leader("lr", vim.lsp.buf.references, { buffer = buffer, desc = "Show lsp references", check = true })

    map.leader(
        { "n", "v", "x" },
        "la",
        vim.lsp.buf.code_action,
        { buffer = buffer, desc = "Open code action menu at cursor or in a range", check = true }
    )

    local lsp_method = "textDocument/definition"
    local selector = "fzf"

    -- Use the good old ALE mappings :)
    map.n.leader(
        "as",
        lsp_request_jump(lsp_method, "split", selector),
        with_desc("Jump to definition in a horizontal split")
    )
    map.n.leader(
        "av",
        lsp_request_jump(lsp_method, "vsplit", selector),
        with_desc("Jump to definition in a vertical split")
    )
    map.n.leader("at", lsp_request_jump(lsp_method, "tabe", selector), with_desc("Jump to definition in a tab"))
end

return lsp_on_attach
