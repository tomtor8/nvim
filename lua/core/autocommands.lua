local a = vim.api

-- Master table for groups {{{1
local groups = {
	yank = a.nvim_create_augroup("YankHighlight", { clear = true }),
	labels = a.nvim_create_augroup("CommentLabels", { clear = true }),
	position = a.nvim_create_augroup("LastPosition", { clear = true }),
	clear_msg = a.nvim_create_augroup("ClearMsgGroup", { clear = true }),
}

-- MiniFiles customize windows {{{1
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesWindowOpen",
	callback = function(args)
		local win_id = args.data.win_id
		-- Customize window-local settings
		-- vim.wo[win_id].winblend = 50
		local config = vim.api.nvim_win_get_config(win_id)
		config.border, config.title_pos = "rounded", "right"
		vim.api.nvim_win_set_config(win_id, config)
	end,
})

-- Highlight on yank {{{1
a.nvim_create_autocmd("TextYankPost", {
	group = groups.yank,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

-- Note, fixme and todo labels {{{1
a.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	group = groups.labels,
	callback = function()
		vim.fn.matchadd("TodoLabel", "TODO:")
		vim.fn.matchadd("FixmeLabel", "FIXME:")
		vim.fn.matchadd("NoteLabel", "NOTE:")
	end,
})

-- Return to last edit position {{{1
a.nvim_create_autocmd("BufReadPost", {
	group = groups.position,
	desc = "Jump to last edit position",
	callback = function()
		local mark = a.nvim_buf_get_mark(0, '"')
		local lcount = a.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(a.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Auto clear the command line {{{1
a.nvim_create_autocmd({ "BufWritePost", "TextYankPost" }, {
	group = groups.clear_msg,
	callback = function()
		vim.defer_fn(function()
			if vim.fn.getcmdtype() == "" then
				a.nvim_echo({ { "" } }, false, {})
			end
		end, 5000)
	end,
})
