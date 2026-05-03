local highlights = {
	Comment = { fg = "#636A72", italic = true },
	Constant = { fg = "#D2A6FF" },
	-- CursorLine = { bg = "none", underline = true, sp = "#454B55" },
	CursorLine = { bg = "none" },
	CursorLineNr = { fg = "#E6B450", bold = true, italic = true },
	FixmeLabel = { fg = "#0B0E14", bg = "#FF3333", bold = true },
	FloatBorder = { fg = "#58606E", bg = "none" }, -- dg windows border
	-- MiniFilesBorder = { fg = "#B3B1AD" }, -- dg windows border
	MiniFilesCursorLine = { fg = "#E6B450", bg = "none", bold = true }, -- dg windows border
	NormalFloat = { bg = "none" }, -- dg windows background color
	Function = { fg = "#FFB454" },
	LineNr = { fg = "#454B55", italic = true },
	MiniPickMatchCurrent = { fg = "#E6B450", bg = "none", bold = true },
	NonText = { fg = "#505662", italic = false }, -- wrap markers inherit from LineNr
	Normal = { fg = "#B3B1AD", bg = "none" },
	NoteLabel = { fg = "#0B0E14", bg = "#5CCFE6", bold = true },
	Pmenu = { fg = "#BFBDB6", bg = "none" }, -- complete menu box --#161922
	PmenuSel = { fg = "#e6b450", bg = "none", bold = true}, -- complete menu selection
	Search = { fg = "#0B0E14", bg = "#E6B450" },
	Special = { fg = "#5CCFE6" },
	Statement = { fg = "#5CCFE6", bold = true },
	StatusCommand = { fg = "#0B0E14", bg = "#A37ACC", bold = true },
	StatusInsert = { fg = "#0B0E14", bg = "#55B4D4", bold = true },
	StatusError = { fg = "#F07178", bg = "none", bold = true },
	StatusGit = { fg = "#636A72", italic = false },
	StatusLine = { fg = "#BFBDB6", bg = "#161922" },
	StatusLspName = { fg = "#636A72", bg = "none", italic = false },
	StatusNormal = { fg = "#0B0E14", bg = "#B8CC52", bold = true },
	StatusReplace = { fg = "#0B0E14", bg = "#F07178", bold = true },
	StatusVisual = { fg = "#0B0E14", bg = "#F29668", bold = true },
	StatusWarn = { fg = "#f29718", bg = "none", bold = true },
	String = { fg = "#AAD94C" },
	TabSeparator = { fg = "#252B35", bg = "#0B0E14" },
	TodoLabel = { fg = "#0B0E14", bg = "#90dec5", bold = true },
	Visual = { bg = "#274364" },
}

for group, settings in pairs(highlights) do
	pcall(vim.api.nvim_set_hl, 0, group, settings)
end

-- enable transparency
-- keep the StatusLine and StatusLineNC opaque
local function transparent_background()
	local groups = {
		"NormalFloat",
		"SignColumn",
		"Folded",
		"EndOfBuffer",
		-- "WinBar",
		-- "WinBarNC",
	}
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { bg = "NONE" })
	end
end

-- Execute the function
transparent_background()
