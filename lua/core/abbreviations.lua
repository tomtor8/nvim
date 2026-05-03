-- 1. Use 'i' (Insert mode) for special punctuation and Spanish characters
-- This triggers INSTANTLY (no Space needed)
-- if you need to write e.g. !!! press Ctrl-V in insert mode and then write
-- uncomment the instant_maps and the for key, val in pairs ...
-- to have global accented characters

-- local instant_maps = {
-- 	[",nn"] = "ñ",
-- 	[",aa"] = "á",
-- 	[",cc"] = "ç",
-- 	[",ee"] = "é",
-- 	[",ii"] = "í",
-- 	[",oo"] = "ó",
-- 	[":uu"] = "ü",
-- 	[":oo"] = "ö",
-- 	[";oo"] = "ő",
-- 	[";uu"] = "ű",
-- 	[",uu"] = "ú",
-- 	[",NN"] = "Ñ",
-- 	[",AA"] = "Á",
-- 	[",CC"] = "Ç",
-- 	[",EE"] = "É",
-- 	[",II"] = "Í",
-- 	[",OO"] = "Ó",
-- 	[":UU"] = "Ü",
-- 	[":OO"] = "Ö",
-- 	[";OO"] = "Ő",
-- 	[";UU"] = "Ű",
-- 	[",UU"] = "Ú",
-- 	["!!!"] = "¡!<Left>",
-- 	["???"] = "¿?<Left>",
-- }

-- for key, val in pairs(instant_maps) do
-- 	vim.keymap.set("i", key, val, { noremap = true, silent = true })
-- end

-- 2. Use 'iabbrev' ONLY for alphanumeric words
-- This triggers after you hit SPACE
local words = {
	emg = "tomas.torday@gmail.com",
	emm = "tomas.torday@medicyt.sk",
    ff1 = "{{{1"
}

for abbr, expansion in pairs(words) do
	vim.cmd(string.format("iabbrev %s %s", abbr, expansion))
end
