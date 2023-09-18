local api = vim.api
local util = require("diaglist.util")
local debounce_trailing = require("diaglist.debounce").debounce_trailing

local M = {}

M.last_priority_uri = nil
M.title = "Workspace Diagnostics"
M.change_since_render = false

local function is_open()
    return vim.fn.getqflist({ title = 0 }).title == M.title
end

M.populate_qflist = function()
    local priority_uri = vim.uri_from_bufnr(0)

    -- entering same buffer as we were before focusing quickfix
    if not M.change_since_render and priority_uri == M.last_priority_uri then
        return
    end

    if string.sub(priority_uri, 0, 7) == "file://" and string.len(priority_uri) > 7 then
        M.last_priority_uri = priority_uri
    else
        priority_uri = M.last_priority_uri
    end

    local all_diagnostics = util.get_qflist({
        priority_uri = priority_uri,
        bufnr = nil,
    })

    if #all_diagnostics > 0 then
        vim.fn.setqflist({}, "r", { title = M.title, items = all_diagnostics })
    else
        api.nvim_command("cclose")
    end
    M.change_since_render = false
end

M.open_all_diagnostics = function()
    M.populate_qflist()
    api.nvim_command("copen")
end

M.diagnostics_hook = function()
    M.change_since_render = true

    if is_open() then
        M.debounced_populate_qflist()
    elseif M.debug then
        vim.notify("foreign quickfix, not populating", vim.log.levels.DEBUG)
    end
end

function M.init()
    M.debounced_populate_qflist = debounce_trailing(M.debounce_ms, M.populate_qflist)

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        pattern = "*",
        group = M.augroup,
        callback = function()
            M.diagnostics_hook()
        end,
    })
end

return M
