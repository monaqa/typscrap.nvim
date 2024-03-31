local M = {}

---@param t {root_dir: string}
function M.set(t)
    M.root_dir = vim.fn.expand(t.root_dir)
end

return M
