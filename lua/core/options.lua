local o = vim.opt
local g = vim.g

-- 1. CORE BEHAVIOR & NATIVE COMPLETION (0.12+) {{{1
-- o.autocomplete = false        -- Native auto-popup completion
-- o.autocompletedelay = 500    -- Milliseconds before popup appears
o.completeopt = "menuone,noselect" -- 0.12 recommends 'popup' for docs
o.undofile = true -- Persistent undo
o.updatetime = 250 -- Speed of diagnostic/completion updates
o.timeoutlen = 400 -- Mapping delay
o.mouse = "a"
o.hidden = true
o.confirm = true
o.autowrite = true

-- 2. UI & VISUALS {{{1
o.termguicolors = true
o.number = true
o.relativenumber = false
o.cursorline = true
o.signcolumn = "number"
o.showmode = false -- Statusline usually handles this
o.laststatus = 3 -- Global statusline

-- Scrolling & Splits
o.scrolloff = 8
o.sidescrolloff = 8
o.splitbelow = true
o.splitright = true

-- Whitespace Rendering
o.list = true
o.listchars = {
	-- tab = "▸ ",
	trail = "·",
	-- leadmultispace = "   ",
	extends = "»", -- Text continues right
	precedes = "«", -- Text continues left
	-- create non-breaking space Ctrl+v then `u` then `00a0`
	nbsp = "␣", -- Non-breaking space
}
o.fillchars:append({ vert = "│", eob = " ", fold = " " })
o.wrap = false
o.showbreak = "» "
o.cpoptions:append("n")
o.showmatch = true

-- 3. SEARCH & NAVIGATION {{{1
o.ignorecase = true
o.smartcase = true
o.path:append({ "**" })
o.shortmess:append("cIOSat") -- 'c' is vital for cleaner native completion

-- Command Line & Wildmenu
o.cmdheight = 1
o.wildmenu = true
o.wildmode = "longest:full,full"
o.wildoptions = "pum"
o.pumheight = 10
o.pumblend = 0
o.pumborder = "rounded"
o.wildignorecase = true

-- Dictionaries & Completion Sources
o.dictionary:append("~/Code/dotfiles/dics/spanish.txt")
o.wildignore:append({
	"*/.git/*",
	"*/node_modules/*",
	"*/.venv/*",
	"*/build/*",
	"*/dist/*",
	"*.pyc",
	"__pycache__",
	"*.DS_Store",
	"*.swp",
	"*/.local/share/*",
})

-- 4. INDENTATION & TABS {{{1
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.smartindent = true
o.breakindent = true

-- 5. FILE EXPLORER (NETRW) & AUTOMATION {{{1
g.netrw_banner = 0
g.netrw_browse_split = 4
g.netrw_liststyle = 3
g.netrw_winsize = 33

-- Auto-cleanup empty ghost buffers after opening netrw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		local prev_buf = vim.fn.bufnr("#")
		if vim.api.nvim_buf_is_valid(prev_buf) then
			local name = vim.api.nvim_buf_get_name(prev_buf)
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = prev_buf })
			if name == "" and buftype == "" then
				vim.api.nvim_buf_delete(prev_buf, { force = true })
			end
		end
	end,
})
