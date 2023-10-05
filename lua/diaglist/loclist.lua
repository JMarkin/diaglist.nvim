local api = vim.api
local util = require("diaglist.util")
local debounce_trailing = require("diaglist.debounce").debounce_trailing

local M = {}

M.title = "Buffer Diagnostics"

M.close_loclist = function(winnr)
    local ll = vim.fn.getloclist(winnr, { all = 0 })
    if ll.winid ~= 0 then
        pcall(vim.api.nvim_win_close, ll.winid, true)
    end
end

M.populate_loclist = function(winnr, bufnr)
    local buf_diag = util.get_qflist({
        bufnr = bufnr,
    })

    vim.fn.setloclist(winnr, {}, "r", { title = M.title, items = buf_diag })
    if #buf_diag == 0 then
        M.close_loclist(winnr)

        local autocmds = vim.api.nvim_get_autocmds({
            group = M.augroup,
            event = "DiagnosticChanged",
            buffer = bufnr
        })
        for _, au in ipairs(autocmds) do
            vim.api.nvim_del_autocmd(au.id)
        end
    end
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
            M.debounced_populate_loclist(winnr, bufnr)
        end,
    })

    M.populate_loclist(winnr, bufnr)
    api.nvim_command("lopen")
end

return M
