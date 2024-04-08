local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local displayer = entry_display.create {
    separator = " ",
    items = {
        { width = 10 },
        { width = 2 },
        { remaining = true },
    },
}

function M.contents(opts)
    local fn = function()
        return require("typscrap").open_content_complete("", "", 1)
    end

    local entry_maker = function(entry)
        local dir = require("typscrap.config").root_dir .. "/" .. entry
        local index_file = vim.fn.resolve(vim.fn.expand(dir .. "/index.typ"))
        return {
            value = entry,
            ordinal = entry,
            display = entry,
            path = index_file,
        }
    end

    pickers
        .new(opts, {
            prompt_title = "Typscrap Content",
            finder = finders.new_dynamic { fn = fn, entry_maker = entry_maker },
            sorter = conf.generic_sorter(opts),
            previewer = conf.file_previewer(opts),
        })
        :find()
end

return M
