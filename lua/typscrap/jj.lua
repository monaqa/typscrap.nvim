-- jj integration
local M = {}

local config = require("typscrap.config")

local function today_description()
    return vim.fn.strftime("%Y/%m/%d") .. " update"
end

local function check_jj_executable()
    return vim.fn.executable("jj") == 1
end

function M.new_with_date()
    if not check_jj_executable() then
        return
    end

    local result = vim.system({
        "jj",
        "log",
        "-r",
        [[committer_date(after:"1 day ago")]],
        "-T",
        [[concat(description.first_line(), "\n")]],
        "--no-graph",
    }, {
        cwd = config.root_dir,
    }):wait()

    local desc = today_description()
    if result.stdout:find(desc, 0, true) ~= nil then
        return
    end

    result = vim.system({
        "jj",
        "new",
        "-m",
        desc,
    }, {
        cwd = config.root_dir,
    }):wait()

    if result.code == 0 then
        vim.notify([[jj new -m "]] .. desc .. [["]])
    end
end

return M
