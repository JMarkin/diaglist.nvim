local M = {
    debug = false,
    buf_clients_only = true,
    debounce_ms = 150,
}

local q = require('diaglist.quickfix')
local l = require('diaglist.loclist')

function M.init(opts)
    local diag_group = vim.api.nvim_create_augroup("diagnostics", { clear = true })

    if opts == nil then
        opts = {}
    end

    if opts['debug'] ~= nil then
        M.debug = opts['debug']
    end

    q.loglevel = M.debug
    l.debug = M.debug
    l.augroup = diag_group
    q.augroup = diag_group

    if opts['debounce_ms'] ~= nil then
        M.debounce_ms = opts['debounce_ms']
    end

    q.debounce_ms = M.debounce_ms
    l.debounce_ms = M.debounce_ms
    if opts['buf_clients_only'] ~= nil then
        M.buf_clients_only = opts['buf_clients_only']
    end

    q.buf_clients_only = M.buf_clients_only

    q.init()
    l.init()

    if M.debug then
        vim.notify(string.format("debounce ms %s", M.debounce_ms), vim.log.levels.DEBUG)
    end
end

function M.open_buffer_diagnostics()
    l.open_buffer_diagnostics()
end

function M.open_all_diagnostics()
    q.open_all_diagnostics()
end

M.setup = M.init

return M
