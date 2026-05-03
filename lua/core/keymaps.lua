local k = vim.keymap

-- -- Load snippets from json {{{1
-- local function expand_by_ft(prefix)
-- 	local ft = vim.bo.filetype
-- 	local config_path = vim.fn.stdpath("config") .. "/snippets/"
-- 	local json_path = config_path .. ft .. ".json"
--
-- 	local snippets = {}
--
-- 	if vim.fn.filereadable(json_path) == 1 then
-- 		local status, data = pcall(function()
-- 			return vim.json.decode(table.concat(vim.fn.readfile(json_path), "\n"))
-- 		end)
-- 		if status then
-- 			snippets = data
-- 		end
-- 	end
--
-- 	-- 3. Search and Expand
-- 	for _, snippet in pairs(snippets) do
-- 		if snippet.prefix == prefix then
-- 			local body = type(snippet.body) == "table" and table.concat(snippet.body, "\n") or snippet.body
--
-- 			return pcall(vim.snippet.expand, body)
-- 		end
-- 	end
--
-- 	return false
-- end

-- Insert mode {{{1
-- [Shift] <Tab> in autocomplete {{{2
-- k.set("i", "<Tab>", function()
-- 	if vim.fn.pumvisible() == 1 then
-- 		return "<C-n>"
-- 	else
-- 		return "<Tab>"
-- 	end
-- end, { expr = true })
--
-- k.set("i", "<S-Tab>", function()
-- 	if vim.fn.pumvisible() == 1 then
-- 		return "<C-p>"
-- 	else
-- 		return "<S-Tab>"
-- 	end
-- end, { expr = true })

-- -- Expand snippets C-J {{{2
-- k.set("i", "<C-j>", function()
-- 	local cursor = vim.api.nvim_win_get_cursor(0)
-- 	local row, col = cursor[1], cursor[2]
-- 	local line = vim.api.nvim_get_current_line()
-- 	local prefix = vim.fn.matchstr(line:sub(1, col), [[\k*$]])
--
-- 	if prefix == "" then
-- 		return
-- 	end
--
-- 	local start_col = col - #prefix
--
-- 	-- We use pcall here as a safety net for the entire operation
-- 	local success, expanded = pcall(function()
-- 		-- Delete prefix
-- 		vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {})
-- 		vim.api.nvim_win_set_cursor(0, { row, start_col })
-- 		-- Attempt expansion
-- 		return expand_by_ft(prefix)
-- 	end)
--
-- 	-- If expansion failed, restore the prefix text so you don't lose your work
-- 	if not success or not expanded then
-- 		vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, start_col, { prefix })
-- 		vim.api.nvim_win_set_cursor(0, { row, col })
-- 	end
-- end, { desc = "Safe Snippet Expand" })

-- JK to escape {{{2
k.set("i", "jk", "<Esc>", { desc = "Exit to Normal Mode", noremap = true, silent = true })

-- <Enter> selects completion {{{2
-- k.set("i", "<CR>", function()
--   if vim.fn.pumvisible() ~= 0 then
--     -- Check if an item is actually highlighted/selected
--     local info = vim.fn.complete_info({"selected"})
--     if info.selected ~= -1 then
--       return "<C-y>" -- Confirm the selection
--     end
--     -- If the menu is open but nothing is highlighted, 
--     -- close the menu and just start a new line
--     return "<C-e><CR>"
--   end
--   return "<CR>"
-- end, { expr = true, desc = "Smart Enter for completion" })

-- Auto-close brackets and quotes {{{2
-- local pairs_map = {
-- 	["("] = ")",
-- 	["["] = "]",
-- 	["{"] = "}",
-- 	["'"] = "'",
-- 	['"'] = '"',
-- }

-- for open, close in pairs(pairs_map) do
-- 	k.set("i", open, function()
-- 		local col = vim.fn.col(".")
-- 		local line = vim.fn.getline(".")
-- 		local char_after = line:sub(col, col)
-- 		local char_before = line:sub(col - 1, col - 1)
-- 		-- 1. Apostrophe check: if previous char is a letter, just type '
-- 		if open == "'" and char_before:match("%a") then
-- 			return open
-- 		end
-- 		-- 2. Look-ahead check: if next char is alphanumeric, don't pair
-- 		if char_after:match("%w") then
-- 			return open
-- 		end
-- 		-- 3. Default: pair them up
-- 		return open .. close .. "<Left>"
-- 	end, { expr = true })
-- end

-- Get out of enclosing brackets or quotes C-K {{{2
k.set("i", "<C-k>", function()
	local col = vim.fn.col(".")
	local line = vim.fn.getline(".")
	local char_after = line:sub(col, col)

	-- If the next character is a closing symbol, move past it
	if char_after:match("[%])}%'\"]") then
		return "<Right>"
	else
		return "<End>"
	end
end, { expr = true })

-- Path completion {{{2
-- Instead of C+x and C+f for path autocomplete
-- This makes the completion menu stay open or re-trigger easily
k.set("i", "<C-f>", "<C-x><C-f>", { desc = "Path completion" })

-- Omnifunc LSP completions {{{2
-- k.set("i", "<C-space>", "<C-x><C-o>", { desc = "LSP completion" })

-- Normal mode {{{1
-- Toggle cmdheight between 0 and 1 {{{2
vim.keymap.set("n", "<leader>h", function()
	if vim.opt.cmdheight:get() == 0 then
		vim.opt.cmdheight = 1
		print("Command line: ON")
	else
		vim.opt.cmdheight = 0
	end
end, { desc = "Toggle cmdheight" })

-- Show full error message in floating window {{{2
k.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })


-- Quickfix list {{{2
-- List all errors in the project
k.set("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Open diagnostic [Q]uickfix list" })

-- Open & Close terminal {{{2
k.set("n", "<leader>tt", function()
	vim.cmd("split | term")
	vim.cmd("resize 10")
	vim.cmd("startinsert")
end, { desc = "Toggle Terminal" })

-- Make exiting Terminal mode easier (Esc to return to Normal mode in term)
k.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Toggle invisible characters (list mode) {{{2
k.set("n", "<leader>i", "<cmd>set list!<CR>", { silent = true })

-- Toggle relativenumbers {{{2
-- Toggle relative numbers with visual feedback
vim.keymap.set("n", "<leader>tr", function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
	-- Optional feedback (uses your existing message clearing logic)
	local status = vim.opt.relativenumber:get() and "Enabled" or "Disabled"
	vim.api.nvim_echo({ { "Relative Number: " .. status, "None" } }, false, {})
end, { silent = true, desc = "Toggle relative line numbers" })

-- Toggle wrap and linebreak {{{2
k.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
	vim.opt.linebreak = not vim.opt.linebreak:get()
	-- Optional: Print a status message to the command line
	local status = vim.opt.wrap:get() and "Enabled" or "Disabled"
	print("Wrap/Linebreak: " .. status)
end, { silent = true, desc = "Toggle Wrap and Linebreak" })

-- Toggle Netrw in a vertical split {{{2
-- k.set("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "Toggle Explorer" })
-- open MiniFiles
k.set("n", "<leader>e", "<cmd>lua MiniFiles.open()<CR>", { desc = "Open File Explorer" })

-- Motions & Jumps {{{2
-- Line jumps {{{3
k.set("n", "gh", "^", { desc = "Move to start of line", silent = true })
k.set("n", "gl", "$", { desc = "Move to end of line", silent = true })
-- Diagnostic jumps {{{3
-- Jump to the previous diagnostic (up)
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })

-- Jump to the next diagnostic (down)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })

-- Clear highlights {{{2
k.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Buffers {{{2
-- Navigate buffers using Shift + h/l
-- :bnext and :bprevious are the built-in commands for this
k.set("n", "L", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
k.set("n", "H", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
-- Close the current buffer
k.set("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close buffer", silent = true })

-- Search & Substitute {{{2

-- Find files with :Pick files
k.set("n", "<leader>ff", "<cmd>Pick files<CR>", { desc = "Pick files in cwd" })
k.set("n", "<leader>fo", "<cmd>Pick old files<CR>", { desc = "Pick old files" })
k.set("n", "<leader>fh", "<cmd>Pick explorer cwd='/home/tom'<CR>", { desc = "Explore Home" })
k.set("n", "<leader>fn", "<cmd>Pick explorer cwd='/home/tom/Documents/notes'<CR>", { desc = "Explore Notes" })
k.set("n", "<leader>fD", "<cmd>Pick explorer cwd='/home/tom/Documents'<CR>", { desc = "Explore Documents" })
k.set("n", "<leader>fc", "<cmd>Pick explorer cwd='/home/tom/.config'<CR>", { desc = "Explore Configs" })
k.set("n", "<leader>fp", "<cmd>Pick explorer cwd='/home/tom/Projects'<CR>", { desc = "Explore Projects" })
k.set("n", "<leader>fd", "<cmd>Pick explorer cwd='/home/tom/Code/dotfiles'<CR>", { desc = "Explore Dotfiles" })
k.set("n", "<leader>fr", "<cmd>Pick grep_live<CR>", { desc = "Grep files with Pick" })

-- Substitute in very magic mode
k.set("n", "<C-s>", [[:%s/\v]], { desc = "Substitute in very magic mode" })
k.set("v", "<C-s>", [[:%s/\v]], { desc = "Substitute in very magic mode" })

-- Keep search results centered
k.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
k.set("n", "N", "Nzzzv", { desc = "Previous search match (centered)" })

-- Start search in "very magic" mode
k.set("n", "/", [[/\v]])
k.set("n", "?", [[?\v]])
k.set("v", "/", [[/\v]])

-- Search and replace word under cursor
k.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gIc<Left><Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)

-- System clipboard {{{2
k.set("n", "YY", "<cmd>%y+<CR>", { desc = "Yank entire document to clipboard" })

-- Visual mode {{{1
-- Move text up and down in Visual Mode {{{2
k.set("v", "J", "<cmd>m '>+1<CR>gv=gv", { desc = "Move block down" })
k.set("v", "K", "<cmd>m '<-2<CR>gv=gv", { desc = "Move block up" })

-- Stay in visual mode while indenting {{{2
k.set("v", "<", "<gv")
k.set("v", ">", ">gv")

-- -- Add surrounding chars {{{2
-- local surround_chars = {
-- 	["("] = ")",
-- 	["["] = "]",
-- 	["{"] = "}",
-- 	["'"] = "'",
-- 	['"'] = '"',
-- 	["`"] = "`",
-- 	["*"] = "*",
-- 	["_"] = "_",
-- 	["<"] = ">",
-- }
--
-- -- Disable the default 's' in Visual and Normal mode
-- -- so it can be used exclusively as a prefix
-- k.set("n", "s", "<Nop>", { silent = true })
--
-- -- Map 's' once to a function that waits for a single character input
-- k.set("x", "s", function()
-- 	-- Wait for the user to type the next character (no timeout applies here!)
-- 	local char = vim.fn.getcharstr()
-- 	local close = surround_chars[char]
--
-- 	if close then
-- 		-- Execute the surround logic
-- 		local cmd = string.format('c%s<C-r>"%s<Esc>', char, close)
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
-- 	else
-- 		-- If the char isn't in our list, just put 's' back or do nothing
-- 		print("Invalid surround character: " .. char)
-- 	end
-- end, { desc = "Custom Surround Menu" })

-- VISUAL MODE EXCLUDING SELECT MODE
-- Paste without losing the original yank
k.set("x", "<leader>p", [["_dP]])

