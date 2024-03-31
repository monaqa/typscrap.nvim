local M = {}

local config = require("typscrap.config")

---@param value number | string | boolean | nil
---@return boolean
local function to_bool(value)
    if value == 0 or value == "" or value == false or value == nil then
        return false
    end
    return true
end

function M.setup(t)
    config.set(t)

    vim.api.nvim_create_user_command("Typscrap", function(meta)
        M.open_content(meta.args)
    end, {
        nargs = "?",
        complete = M.open_content_complete,
    })
end

local template = {
    index_file = function(slug)
        return {
            [[//! target: ./preview.typ]],
            [[#import "@local/class-typscrap:0.1.0": component; #import component: *]],
            ([[#meta(slug: "%s")]]):format(slug),
            [[]],
            [[= ]],
        }
    end,
    preview_file = function(slug)
        return {
            [[#import "@local/class-typscrap:0.1.0": layout]],
            [[]],
            [[#show: layout.document]],
            [[]],
            [[#include "index.typ"]],
        }
    end,
}

function M.open_content(slug)
    if slug == "" then
        local s, e, user, repo = vim.fn.getcwd():find(vim.env.HOME .. "/ghq/.*/(.*)/(.*)")
        if repo == nil then
            slug = "."
        else
            slug = ("in_project/%s/%s"):format(user, repo)
        end
    end

    local dir = config.root_dir .. "/" .. slug
    local index_file = vim.fn.resolve(vim.fn.expand(dir .. "/index.typ"))
    local preview_file = vim.fn.resolve(vim.fn.expand(dir .. "/preview.typ"))
    vim.cmd.edit(index_file)

    if not to_bool(vim.fn.filereadable(index_file)) then
        vim.fn.mkdir(dir, "p")
        vim.fn.writefile(template.preview_file(slug), preview_file)
        vim.fn.setline(1, template.index_file(slug))
    end
end

function M.open_content_complete(arglead, cmdline, cursorpos)
    local paths = vim.split(vim.fn.globpath(config.root_dir, "*/**/index.typ"), "\n", { plain = true })
    local query = "^" .. table.concat(vim.split(arglead, ""), ".*")

    local cands = vim.tbl_map(function(path)
        return path:sub(#config.root_dir + 2, #path - 10)
    end, paths)
    cands = vim.tbl_filter(function(cand)
        return cand:find(query)
    end, cands)
    cands = vim.fn.reverse(cands)

    return cands
end

return M
