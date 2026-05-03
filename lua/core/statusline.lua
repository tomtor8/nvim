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


-- New: LSP Progress using 0.12 native API {{{1
local function get_lsp_progress()
    -- This returns a string like "Searching..." or "Indexing..."
    local progress = vim.ui.progress_status()
    if progress == "" then return "" end
    return string.format(" %%#StatusLspName#%s%%#StatusLine# ", progress)
end

-- New: Terminal Exit Code {{{1
local function get_terminal_status()
    -- Check if we are in a terminal buffer and it has exited
    if vim.bo.buftype ~= "terminal" then return "" end
    
    -- Neovim sets b:terminal_job_status on exit
    local status = vim.b.terminal_job_status
    if status then
        local hl = status == 0 and "%#StatusNormal#" or "%#StatusError#"
        return string.format(" %s[Exit: %d]%%#StatusLine# ", hl, status)
    end
    return " %#StatusGit#[Running]%#StatusLine# "
end

-- Main statusline function {{{1
function _G.simple_statusline()
	local mode_info = mode_map[vim.api.nvim_get_mode().mode] or mode_map["n"]
	local current_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	
    -- Search count logic
	local s_info = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
	local search = ""
	if s_info and s_info.total and s_info.total > 0 and vim.v.hlsearch ~= 0 then
		search = string.format(" [%d/%d] ", s_info.current, s_info.total)
	end

    -- 0.12 Native Diagnostics
    -- This automatically handles icons and counts based on your diagnostic config
    local diags = vim.diagnostic.status()
    if diags ~= "" then
        diags = " " .. diags .. " "
    end

	local git = get_git_status()
    local progress = get_lsp_progress()
    local term = get_terminal_status()

	return string.format(
		"%%#%s#%s%%#StatusLine# 󰉋 %s%s %%m%s%s %%=%s%s%%l:%%c %%p%%%% ",
		mode_info.hl,
		mode_info.name,
		current_dir,
        git,
		search,
        term,     -- Shows terminal status if applicable
		diags,    -- Native diagnostic status
		progress  -- Native LSP progress
	)
end

-- Apply the status line
vim.opt.statusline = "%!v:lua.simple_statusline()"
