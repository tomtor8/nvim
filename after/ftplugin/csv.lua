require("core.accented-char-maps").setup() -- import accented char abbreviations

-- Variables {{{1
local a = vim.api
local o = vim.opt_local
local k = vim.keymap

-- Buffer-local settings {{{1
o.wrap = true -- Enable visual wrapping
o.expandtab = false -- Prevent tabs from turning to spaces
o.linebreak = true -- Don't break words in the middle
o.cursorline = true
o.cpoptions:append("n")

-- CSV specific keymaps {{{1
-- Remap <Tab> in Insert mode to insert " | "
--  if you want to have the TAB back in insert mode press Ctrl-V and then <TAB>
-- smart Tab autocompletes when popup menu visible
-- writes pipe if popup menu invisible
k.set("i", "<Tab>", " | ", { desc = "Write pipe" })

k.set("n", "<Tab>", function()
	-- Search for the pipe, move to the end of the match
	if vim.fn.search("| ", "W") ~= 0 then
		vim.cmd("normal! l") -- Move one char right to be inside the column
	end
end, { buffer = true, desc = "Invisible jump" })

-- Rainbow colors {{{1
local column_colors = {
	"#f9e2af", -- 5th: Yellow
	"#fab387", -- 4th: Orange
	"#f38ba8", -- 2nd: Red
	"#cab6f7", -- 7th: Purple
	"#89b4fa", -- 6th: Blue
	"#a6e3a1", -- 3rd: Green
	"#94e2d5", -- 8th: Cyan
}

vim.cmd("syntax clear")

local max_columns = 40

for i = 1, max_columns do
	local group_name = "CsvCol" .. i

	local color
	if i <= #column_colors then
		color = column_colors[i]
	else
		local cycle_index = ((i - 4) % (#column_colors - 3)) + 4
		color = column_colors[cycle_index]
	end

	a.nvim_set_hl(0, group_name, { fg = color, bold = (i == 2) })

	local pattern
	if i == 1 then
		-- Force the first column to match from the very start of the line
		pattern = [[^[^|]*]]
	else
		-- Match after exactly (i-1) pipes
		pattern = string.format([[^\([^|]*|\)\{%d\}\zs[^|]*]], i - 1)
	end

	vim.cmd(string.format([[syntax match %s /%s/]], group_name, pattern))
end

-- Subtly highlight the pipes
a.nvim_set_hl(0, "CsvPipe", { fg = "#444444" })
vim.cmd([[syntax match CsvPipe /|/]])
