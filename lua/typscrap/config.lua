local M = {}

---@class TypscrapConfig
---@field root_dir string
---@field jj_auto_new? boolean

---@param t TypscrapConfig
function M.set(t)
    if t.jj_auto_new == nil then
        t.jj_auto_new = false
    end

    M.root_dir = vim.fn.expand(t.root_dir)
    M.jj_auto_new = t.jj_auto_new
end

return M
