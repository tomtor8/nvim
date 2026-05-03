require("core.accented-char-maps").setup() -- import accented char abbreviations

local o = vim.opt_local
local k = vim.keymap

o.wrap = true          -- Enable visual wrapping
o.expandtab = true     -- tabs turning to spaces
o.linebreak = true      -- Don't break words in the middle
o.cpoptions:append("n") -- Respect line breaks in wrapped lines
o.commentstring = "# %s" -- custom comments also great for folds
vim.fn.matchadd("Comment", "^#.*")

-- Navigate by visual lines instead of logical lines
k.set("n", "j", "gj", { silent = true, desc = "Move down visually" })
k.set("n", "k", "gk", { silent = true, desc = "Move up visually" })

-- Also apply to visual mode so selections follow the wrap
k.set("v", "j", "gj", { silent = true })
k.set("v", "k", "gk", { silent = true })
