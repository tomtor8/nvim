-- Helper to get current Git branch {{{1
local function get_git_status()
	-- Check if gitsigns has already found the branch (efficient)
	local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current 2> /dev/null"):gsub("\n", "")

	if branch == "" then
		return ""
	end

	-- Return the branch with an icon and specific highlighting
	return string.format(" %%#StatusGit# %s%%#StatusLine# ", branch)
end

-- Map of mode codes to display names and highlights {{{1
local mode_map = {
	["n"] = { name = " N ", hl = "StatusNormal" },
	["i"] = { name = " I ", hl = "StatusInsert" },
	["v"] = { name = " V ", hl = "StatusVisual" },
	["V"] = { name = " V-LINE ", hl = "StatusVisual" },
	["\22"] = { name = " V-BLOCK ", hl = "StatusVisual" },
	["c"] = { name = " C ", hl = "StatusCommand" },
	["R"] = { name = " R ", hl = "StatusReplace" },
}

-- Helper to get diagnostic counts {{{1
local function get_diagnostic_status()
	local levels = {
		errors = vim.diagnostic.severity.ERROR,
		warnings = vim.diagnostic.severity.WARN,
	}

	local err = #vim.diagnostic.get(0, { severity = levels.errors })
	local warn = #vim.diagnostic.get(0, { severity = levels.warnings })

	local status = ""
	-- You can replace these icons with whatever your font supports
	if err > 0 then
		status = status .. string.format("%%#StatusError# %d%%#StatusLine# ", err)
	end
	if warn > 0 then
		status = status .. string.format("%%#StatusWarn# %d%%#StatusLine# ", warn)
	end

	return status ~= "" and (status .. " ") or ""
end

-- Helper to get active LSP names {{{1
local function get_lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	-- %%#StatusLspName# starts the grey italics
	-- [%s] is the content
	-- %%#StatusLine# resets the color back to normal
	return string.format(" %%#StatusLspName#[%s]%%#StatusLine# ", table.concat(names, ", "))
end

-- Main statusline function {{{1
function _G.simple_statusline()
	local mode_info = mode_map[vim.api.nvim_get_mode().mode] or mode_map["n"]
	local current_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	local s_info = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
	local search = ""

	if s_info and s_info.total and s_info.total > 0 and vim.v.hlsearch ~= 0 then
		search = string.format(" [%d/%d] ", s_info.current, s_info.total)
	end

	local git = get_git_status()
	local lsp = get_lsp_status()
	local diags = get_diagnostic_status()

	return string.format(
		"%%#%s#%s%%#StatusLine# 󰉋 %s%s %%m%s %%=%s%s%%l:%%c %%p%%%% ",
		mode_info.hl,
		mode_info.name,
		current_dir,
        git,
		search,
		diags, -- Displayed before the LSP name
		lsp
	)
end

-- Apply the status line {{{1
vim.opt.statusline = "%!v:lua.simple_statusline()"
