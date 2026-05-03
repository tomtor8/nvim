local function open_greeter()
	if vim.fn.argc() > 0 or vim.fn.line2byte("$") ~= -1 then
		return
	end

	local bookmarks = {
		{ name = "Configs", path = "~/.config" },
		{ name = "Docs", path = "~/Documents" },
		{ name = "Dotfiles", path = "~/Code/dotfiles" },
	}

	local pad = "    " -- adjustable left padding
	local lines = { "", pad .. "NEOVIM DASHBOARD", "" }
	local section_line_indices = {}
	local shortcut_line_indices = {}

	-- Helper to add sections
	local function add_section(title)
		table.insert(lines, pad .. title)
		table.insert(section_line_indices, #lines - 1)
	end

	-- Section: Actions (Now on separate lines)
	add_section("--- Actions ---")
	table.insert(lines, pad .. "[n] New Buffer")
	table.insert(shortcut_line_indices, #lines - 1)
	table.insert(lines, pad .. "[q] Quit")
	table.insert(shortcut_line_indices, #lines - 1)
	table.insert(lines, "")

	-- Section: Bookmarks
	add_section("--- Bookmarks ---")
	for i, bm in ipairs(bookmarks) do
		table.insert(lines, string.format("%s[%d] %s", pad, i, bm.name))
		table.insert(shortcut_line_indices, #lines - 1)
	end
	table.insert(lines, "")

	-- Section: Recent Files
	add_section("--- Recent ---")
	local recent = vim.tbl_filter(function(f)
		return vim.fn.filereadable(f) == 1
	end, vim.v.oldfiles)
	local recent_keys = { "a", "s", "d" }
	for i = 1, math.min(3, #recent) do
		table.insert(lines, string.format("%s[%s] %s", pad, recent_keys[i], vim.fn.fnamemodify(recent[i], ":~:.")))
		table.insert(shortcut_line_indices, #lines - 1)
	end
	table.insert(lines, "")

	-- Buffer/Window Creation (same as before)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	local ui = vim.api.nvim_list_uis()[1]
	local width, height = 50, #lines
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = (ui.width - width) / 2,
		row = (ui.height - height) / 2,
		style = "minimal",
		border = "rounded",
	})

	-- [[ UNIVERSAL COLOR APPLICATION ]]
	local ns_id = vim.api.nvim_create_namespace("my_greeter")

	-- 1. Title (Green)
	vim.api.nvim_buf_set_extmark(buf, ns_id, 1, 0, {
		end_row = 1,
		end_col = #lines[2],
		hl_group = "String",
	})

	-- 2. Sections (Orange)
	for _, idx in ipairs(section_line_indices) do
		vim.api.nvim_buf_set_extmark(buf, ns_id, idx, 0, {
			end_row = idx,
			end_col = #lines[idx + 1],
			hl_group = "Keyword",
		})
	end

	-- 3. Shortcut Keys (Blue) - One simple rule for everything
	for _, idx in ipairs(shortcut_line_indices) do
		vim.api.nvim_buf_set_extmark(buf, ns_id, idx, #pad, {
			end_col = #pad + 3,
			hl_group = "Directory",
		})
	end

	-- Keybindings and Resize Logic (same as before)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	local function map(key, cb)
		vim.keymap.set("n", key, function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			cb()
		end, { buffer = buf, silent = true })
	end

	map("n", function()
		vim.cmd("enew")
	end)
	map("q", function()
		vim.cmd("qa")
	end)
	for i, bm in ipairs(bookmarks) do
		map(tostring(i), function()
			local exp = vim.fn.expand(bm.path)
			vim.cmd(vim.fn.isdirectory(exp) == 1 and "Lexplore " .. exp or "edit " .. exp)
		end)
	end
	for i = 1, math.min(3, #recent) do
		map(recent_keys[i], function()
			vim.cmd("edit " .. recent[i])
		end)
	end
	-- Place cursor on the 2nd line, 5rd character (1-indexed row, 0-indexed col)
	vim.api.nvim_win_set_cursor(win, { 2, 4 })
end

vim.api.nvim_create_autocmd("VimEnter", { callback = open_greeter })
