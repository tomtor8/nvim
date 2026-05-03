local a = vim.api
local o = vim.opt

a.nvim_set_hl(0, "TabLine", { fg = "#565B66", bg = "#0F131A" }) -- Inactive tabs
a.nvim_set_hl(0, "TabLineSel", { fg = "#0B0E14", bg = "#E6B450", bold = true }) -- Active tab
a.nvim_set_hl(0, "TabLineFill", { bg = "none" }) -- The empty space

-- The click handler must be global (_G) to be visible to the statusline
function _G.switch_buffer_click(bufnr, _, button, _)
	-- bufnr: The ID we passed in the tabline
	-- clicks: Number of clicks (usually 1)
	-- button: "l" for left, "r" for right, etc.
	if button == "l" then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

function _G.simple_bufferline()
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	local cur_buf = a.nvim_get_current_buf()
	local cur_idx = 1

	-- 1. Find the index of the current buffer
	for i, buf in ipairs(bufs) do
		if buf.bufnr == cur_buf then
			cur_idx = i
			break
		end
	end

	-- 2. Calculate available width (leaving a small margin)
	local available_width = vim.o.columns - 10
	local current_width = 0
	local start_idx, end_idx = cur_idx, cur_idx

	-- Helper to estimate the width of a single tab
	local function get_tab_width(buf)
		local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":t") or "[No Name]"
		local modified = a.nvim_get_option_value("modified", { buf = buf.bufnr }) and 3 or 0
		return #name + modified + 4 -- padding + separator
	end

	-- 3. Expand the "window" of visible buffers bi-directionally
	current_width = get_tab_width(bufs[cur_idx])
	while true do
		local expanded = false
		-- Try to add a buffer to the left
		if start_idx > 1 then
			local w = get_tab_width(bufs[start_idx - 1])
			if current_width + w < available_width then
				start_idx = start_idx - 1
				current_width = current_width + w
				expanded = true
			end
		end
		-- Try to add a buffer to the right
		if end_idx < #bufs then
			local w = get_tab_width(bufs[end_idx + 1])
			if current_width + w < available_width then
				end_idx = end_idx + 1
				current_width = current_width + w
				expanded = true
			end
		end
		if not expanded then
			break
		end
	end

	-- 4. Build the string only for the visible range
	local s = ""
	if start_idx > 1 then
		s = "%#TabLine# 󰇘 "
	end -- Left indicator

	for i = start_idx, end_idx do
		local buf = bufs[i]
		local is_active = buf.bufnr == cur_buf

		s = s .. (is_active and "%#TabLineSel#" or "%#TabLine#")
		s = s .. "%" .. buf.bufnr .. "@v:lua.switch_buffer_click@"

		local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":t") or "[No Name]"
		local modified = a.nvim_get_option_value("modified", { buf = buf.bufnr }) and " 󰰐" or ""
		s = s .. " " .. name .. modified .. " "
		s = s .. "%X"

		if i < end_idx then
			s = s .. "%#TabSeparator#│"
		end
	end

	if end_idx < #bufs then
		s = s .. "%#TabLine# 󰇘 "
	end -- Right indicator

	s = s .. "%#TabLineFill#%T"
	return s
end

-- apply bufferline
o.tabline = "%!v:lua.simple_bufferline()"
o.showtabline = 2 -- set to 0 to disable

-- Active: Gold and Bold
a.nvim_set_hl(0, "WinBar", { fg = "#BFBDB6", bg = "#161922", bold = true })
-- Inactive: Muted Grey
a.nvim_set_hl(0, "WinBarNC", { fg = "#565B66", bg = "#161922", italic = true })

function _G.simple_winbar()
	local winid = vim.g.statusline_winid or 0
	local curwin = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local file_path = vim.api.nvim_buf_get_name(bufnr)

	if file_path == "" then
		return ""
	end

	local is_active = (winid == curwin)

	-- We use the standard atoms. Neovim handles the 'switching' logic.
	local hl = is_active and "%#WinBar#" or "%#WinBarNC#"
	local icon = is_active and "󰈈 " or "󰈉 "

	-- Path logic
	local home = os.getenv("HOME")
	local display_path = file_path
	if home and file_path:find(home, 1, true) == 1 then
		display_path = "~" .. file_path:sub(#home + 1)
	end
	-- if you want shortened path uncomment next line
	-- and modify the return string.format()
	-- local shortened = vim.fn.pathshorten(display_path)

	-- Return: Push to right, then apply highlight, icon, and path
	return string.format("%%=%s%s %s ", hl, icon, display_path)
end

-- apply winbar
vim.opt.winbar = "%!v:lua.simple_winbar()"
