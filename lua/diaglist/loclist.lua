local api = vim.api
local util = require("diaglist.util")
local debounce_trailing = require("diaglist.debounce").debounce_trailing

local M = {}

M.title = "Buffer Diagnostics"
M.change_since_render = false

M.populate_loclist = function(winnr, bufnr)
    if not M.change_since_render then
        return
    end

    local buf_diag = util.get_qflist({
        bufnr = bufnr,
    })

    vim.fn.setloclist(winnr, {}, "r", { title = M.title, items = buf_diag })
    M.change_since_render = false
end

function M.init()
    M.debounced_populate_loclist = debounce_trailing(M.debounce_ms, M.populate_loclist)
end

function M.open_buffer_diagnostics()
    local ft = vim.filetype.match({ buf = 0 })
    if not ft or ft == "qf" then
        return
    end
    local bufnr = vim.fn.bufnr()
    local winnr = vim.fn.winnr()
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        buffer = bufnr,
        group = M.augroup,
        callback = function()
            M.change_since_render = true
            M.debounced_populate_loclist(winnr, bufnr)
        end,
    })

    M.change_since_render = true
    M.populate_loclist(winnr, bufnr)
    api.nvim_command("lopen")
end

return M
