-- Helper to get current Git branch {{{1
local function get_git_status()
	local branch = vim.b.gitsigns_head or vim.fn.system("git branch --show-current 2> /dev/null"):gsub("\n", "")

	if branch == "" then
		return ""
	end

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

-- Combined LSP Names and Progress {{{1
local function get_lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end

	-- Collect all active client names
	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	local client_names = table.concat(names, ", ")

	-- Get the 0.12 progress status
	local progress = vim.ui.progress_status()

	-- Format: [lua_ls, rust_analyzer] Indexing...
	local display = string.format("[%s]", client_names)
	if progress ~= "" then
		display = display .. " " .. progress
	end

	return string.format(" %%#StatusLspName#%s%%#StatusLine# ", display)
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

	-- Use 0.12 native diagnostic status
	local diags = vim.diagnostic.status()
	if diags ~= "" then
		diags = " " .. diags .. " "
	end

	local git = get_git_status()
	local lsp = get_lsp_status() -- Now includes names and progress
	-- local term = get_terminal_status()

return string.format(
		"%%#%s#%s%%#StatusLine# 󰉋 %s%s %%m%s %%=%s%s%%l:%%c %%#%s# %%p%%%% ",
		mode_info.hl, -- First use: for the mode name at the start
		mode_info.name,
		current_dir,
		git,
		search,
		diags,
		lsp,
		mode_info.hl -- Second use: for the percentage background at the end
	)
end

-- Apply the status line
vim.opt.statusline = "%!v:lua.simple_statusline()"
