vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- FOLDING
-- Make the fold lines look more subtle
vim.api.nvim_set_hl(0, "Folded", { fg = "#5C6773", bg = "NONE", italic = true })
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = "{{{,}}}"

function CustomFoldText()
	local level = vim.v.foldlevel
	local line = vim.fn.getline(vim.v.foldstart)
	-- Clean up: Remove comment characters (#, //, --) and markers
	local cleaned_line = line:gsub("^%s*[#/-]*%s*", "") -- Removes leading comments
	cleaned_line = cleaned_line:gsub("{{{.*", "") -- Removes marker and everything after
	cleaned_line = cleaned_line:gsub("%s*$", "") -- Trims trailing whitespace
	local indent = string.rep("  ", level - 1)
	local icon = "󰉈 " .. level
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	return indent .. icon .. " │ " .. cleaned_line .. " (" .. line_count .. " lines)"
end

vim.opt.foldtext = "v:lua.CustomFoldText()"

vim.keymap.set("i", ",ff", "{{{1", { desc = "Fold marker abbreviation" })

-- LOAD CORE MODULES
require("core.options")

require("core.keymaps")

require("core.commands")

require("core.colors")

require("core.statusline")

require("core.bufferline")

require("core.autocommands")

require("core.abbreviations")

-- require("core.greeter") -- now using mini.starter

require("core.lsp")

-- PLUGINS
-- UPDATE all with command `:lua vim.pack.update()`
-- UPDATE single plugin `:lua vim.pack.update({ 'mini.clue'} )`
-- DELETE: remove it from vim.pack.add()
-- then run `:lua vim.pack.del({ "mini.clue", "mini.surround" })
vim.pack.add({
    "https://github.com/romus204/tree-sitter-manager.nvim",
	"https://github.com/nvim-mini/mini.surround",
	"https://github.com/nvim-mini/mini.clue",
	"https://github.com/nvim-mini/mini.pick",
	"https://github.com/nvim-mini/mini.pairs",
	"https://github.com/nvim-mini/mini.starter",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-mini/mini.completion",
	"https://github.com/nvim-mini/mini.snippets",
	"https://github.com/nvim-mini/mini.files",
	"https://github.com/nvim-mini/mini.extra",
    "https://github.com/antonk52/filepaths_ls.nvim",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
})
-- NOTE install tree-sitter-cli using pacman first!
-- then install language support via :TSManager<CR>
require("tree-sitter-manager").setup()
require('mini.extra').setup()
require('mini.files').setup({
    windows = {
        max_number = 3,
        preview = true,
        width_focus = 35,
        width_nofocus = 15,
        width_preview = 40
    }
})

require("mini.pairs").setup()
require("ibl").setup()

require("mini.surround").setup()

-- mini snippets
local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),
    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

require("mini.icons").setup()

require("mini.completion").setup({
	lsp_completion = {
		source_func = "omnifunc", -- or `completefunc`
	},
})

require("mini.pick").setup({
	window = {
		config = {
			border = "rounded", -- double
		},
	},
})

require("plugins.mini-clue") -- setup in `nvim/lua/plugins`
require("plugins.mini-starter") -- setup in `nvim/lua/plugins`

-- vim: set foldmethod=manual:
