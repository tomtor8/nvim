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
	local s = ""
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	local cur_buf = a.nvim_get_current_buf()

	for i, buf in ipairs(bufs) do
		local is_active = buf.bufnr == cur_buf
		-- Start Highlight Group
		s = s .. (is_active and "%#TabLineSel#" or "%#TabLine#")
		-- ADDED: Start Clickable Area
		-- The syntax is %@Func_Name@ ... %X
		-- We pass the bufnr as the argument to switch_buffer_click
		s = s .. "%" .. buf.bufnr .. "@v:lua.switch_buffer_click@"

		local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":t") or "[No Name]"
		local modified = a.nvim_get_option_value("modified", { buf = buf.bufnr }) and " 󰰐" or ""
		s = s .. " " .. name .. modified .. " "

		-- ADDED: End Clickable Area
		s = s .. "%X"

		if i < #bufs then
			s = s .. "%#TabSeparator#│"
		end
	end

	s = s .. "%#TabLineFill#%="

	-- Add parent directory of the active buffer on the right side
	local cur_name = a.nvim_buf_get_name(cur_buf)
	local dir = (cur_name ~= "") and vim.fn.fnamemodify(cur_name, ":p:h:t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

	s = s .. "%#TabLine# 󰉋 " .. dir .. " "
	return s
end

o.tabline = "%!v:lua.simple_bufferline()"
o.showtabline = 2 -- set to 0 to disable

-- Add padding bewtween bufferline and buffer itself
a.nvim_set_hl(0, "WinBarSpacer", { fg = "#BFBDB6", bg = "#161922" })

function _G.simple_winbar()
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		return "%#WinBarSpacer# ──"
	end

	-- Get the parent folder and the filename
	local parent = vim.fn.fnamemodify(file_path, ":p:h:t")
	local file = vim.fn.fnamemodify(file_path, ":t")

	-- Display: Folder > File ───
	return string.format(
		"%%#WinBarSpacer#  󰉋 %s › 󰈔 %s  ────────────────",
		parent,
		file
	)
end

o.winbar = "%!v:lua.simple_winbar()"
-- o.winbar = "%#WinBarSpacer#────────────────"
-- Shows the directory followed by the line
-- o.winbar = "%#WinBarSpacer# 󰉋 %{v:lua.vim.fn.fnamemodify(v:lua.vim.api.nvim_buf_get_name(0), ':p:h:t')} ──"
