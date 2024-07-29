local M = {}

local augroup = vim.api.nvim_create_augroup("typscrap", { clear = true })

local config = require("typscrap.config")

---@param value number | string | boolean | nil
---@return boolean
local function to_bool(value)
    if value == 0 or value == "" or value == false or value == nil then
        return false
    end
    return true
end

local function find_typscrap_file()
    local file = vim.fn.expand("<cfile>")
    local path = vim.fn.findfile(file .. "/index.typ", config.root_dir)
    if #path == 0 then
        vim.cmd.normal { [[gf]], bang = true }
    else
        vim.cmd.edit(path)
    end
end

function M.setup(t)
    config.set(t)

    vim.api.nvim_create_user_command("Typscrap", function(meta)
        M.open_content(meta.args)
    end, {
        nargs = "?",
        complete = M.open_content_complete,
    })

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = augroup,
        pattern = config.root_dir .. "/*.typ",
        callback = function()
            vim.keymap.set("n", "gf", find_typscrap_file, { buffer = true })
            -- vim.opt_local.path:prepend(config.root_dir)
            -- vim.opt_local.suffixesadd = { ".typ", "/index.typ" }
            -- vim.opt_local.suffixesadd = { "/index.typ" }
            vim.opt_local.omnifunc = "v:lua.typscrap.omni_complete"
        end,
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
        local s, e, user, repo = vim.fn.getcwd():find(vim.env.HOME .. "/ghq/[^/]+/([^/]+)/([^/]+)")
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

---@param arglead string
---@param slug string
---@return integer
local function calc_match_score(arglead, slug)
    if arglead == slug then
        return 5
    end
    if vim.startswith(slug, arglead) then
        return 4
    end
    if slug:find(arglead, 1, true) then
        return 3
    end
    local query = table.concat(vim.split(arglead, ""), ".*")
    if slug:find("^" .. query) ~= nil then
        return 2
    end
    if slug:find(query) ~= nil then
        return 1
    end
    return 0
end

function M.get_buf_slug()
    local bufname = vim.fn.bufname()

    if vim.startswith(bufname, config.root_dir) then
        return bufname:sub(#config.root_dir + 2, #bufname - 10)
    end
end

function M.open_content_complete(arglead, cmdline, cursorpos)
    local paths = vim.split(vim.fn.globpath(config.root_dir, "*/**/index.typ"), "\n", { plain = true })

    local cands = vim.iter(paths)
        :map(function(path)
            local slug = path:sub(#config.root_dir + 2, #path - 10)
            return { slug = slug, score = calc_match_score(arglead, slug) }
        end)
        :filter(function(cand)
            return cand.score > 0
        end)
        :totable()

    table.sort(cands, function(a, b)
        return a.score > b.score
    end)

    return vim.iter(cands)
        :map(function(cand)
            return cand.slug
        end)
        :totable()
end

_G.typscrap = {
    omni_complete = function(findstart, base)
        vim.print { findstart, base }
        if findstart == 1 then
            -- first invocation
            local line = vim.fn.getline(".")
            local start = vim.fn.col(".") - 1
            while start > 0 and line:sub(start, start) ~= [["]] do
                start = start - 1
            end
            vim.print { line = line, col = vim.fn.col("."), start = start }
            return start
        else
            return M.open_content_complete(base)
        end
    end,
}

return M
