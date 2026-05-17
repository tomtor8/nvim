-- for markdown snippets work
-- link the original snippets/markdown.json to
-- nvim/snippets/markdown.json and
-- nvim/snippets/markdown_inline.json
require("core.accented-char-maps").setup()

local o = vim.opt_local
local a = vim.api
local k = vim.keymap

-- 1. Buffer-local settings
o.wrap = true
o.linebreak = true
o.cpoptions:append("n")
o.conceallevel = 3 -- hide some markdown characters
---- concealcursor = "n" does not expand the hidden parts
o.concealcursor = "n"

-- Navigate by visual lines instead of logical lines
k.set("n", "j", "gj", { silent = true, desc = "Move down visually" })
k.set("n", "k", "gk", { silent = true, desc = "Move up visually" })

-- Also apply to visual mode so selections follow the wrap
k.set("v", "j", "gj", { silent = true })
k.set("v", "k", "gk", { silent = true })

-- Toggle conceallevel between 0 and 3
vim.keymap.set("n", "<leader>tc", function()
    local current = vim.opt_local.conceallevel:get()
    if current == 0 then
        vim.opt_local.conceallevel = 3
    else
        vim.opt_local.conceallevel = 0
    end
end, { buffer = true, desc = "Toggle Conceal" })

-- Custom Commands {{{1

-- Create a buffer-local user command :RemoveBold
-- The '0' argument targets the current buffer only
vim.api.nvim_buf_create_user_command(0, "RemoveBold", function(opts)
    -- Save the current cursor position to prevent it from jumping
    local save_cursor = vim.fn.getpos(".")
    -- Determine the range (defaults to whole file '%' if no range is given)
    local range = "%"
    if opts.range > 0 then
        range = string.format("%d,%d", opts.line1, opts.line2)
    end
    -- Run the substitution string safely using Lua's raw string syntax
    -- the `{-}` means non-greedy search
    vim.cmd(string.format([[%ss/\*\*\(.\{-}\)\*\*/\1/ge]], range))
    -- Restore the cursor position
    vim.fn.setpos(".", save_cursor)
end, {
    range = true, -- Allows the command to accept a range (e.g., visual selection)
    desc = "Remove bold markdown formatting from the file or selection",
})

-- Colors & Highlighting {{{1

-- use `:Inspect` command to get the highlight names
-- of the items under cursor in the buffer
-- 3. Highlighting (Tree-sitter compatible for 0.12)

-- Ayu Dark Palette Colors
local bg_dark = "#0f1419" -- Deep background
local tag_color = "#36a3d9" -- Light blue
local keyword = "#ff7733" -- Bright orange
local string = "#f1fa8c" -- Soft yellow
local markup = "#f07178" -- Coral/Pink
local accent = "#d2a6ff" -- Purple
local comment = "#5c6773" -- Muted grey
local green = "#95e6cb" -- Aqua/Green

local header_configs = {
    { fg = "#f07178", bg = "#253340" }, -- H1: Coral
    { fg = "#ffad66", bg = "#253340" }, -- H2: Orange
    { fg = "#ffcc66", bg = "#253340" }, -- H3: Gold
    { fg = "#95e6cb", bg = "#253340" }, -- H4: Aqua
    { fg = "#36a3d9", bg = "#253340" }, -- H5: Blue
    { fg = "#5c6773", bg = "#253340" }, -- H6: Greyish Blue
}

for i = 1, 6 do
    a.nvim_set_hl(0, "@markup.heading." .. i .. ".markdown", {
        fg = header_configs[i].fg,
        bg = header_configs[i].bg,
        bold = true,
    })
end

-- 2. Styling
a.nvim_set_hl(0, "@markup.italic", { italic = true, fg = string })
a.nvim_set_hl(0, "@markup.strong", { bold = true, fg = keyword })

-- 3. Code Elements
-- Inline: High contrast coral on a subtle grey-blue background
a.nvim_set_hl(0, "@markup.raw.markdown_inline", { fg = markup, bg = "#1c2433" })
-- Block: Clean light grey
a.nvim_set_hl(0, "@markup.raw.block.markdown", { fg = "#b3b1ad", bg = "none" })

-- 4. Blockquotes & Lists
a.nvim_set_hl(0, "@markup.quote", { fg = comment, italic = true })
a.nvim_set_hl(0, "@markup.list.markdown", { fg = green })

-- 5. Tables
a.nvim_set_hl(0, "@markup.heading.markdown", { bold = true, fg = tag_color })
-- Punctuation (The dots, dashes, and brackets)
a.nvim_set_hl(0, "@punctuation.special.markdown", { fg = "#475266" })

-- 6. Links and Images
a.nvim_set_hl(0, "@markup.link.markdown_inline", { fg = accent })
a.nvim_set_hl(
    0,
    "@markup.link.label.markdown_inline",
    { fg = accent, underline = true }
)

-- 7. Todo Checks
a.nvim_set_hl(0, "@markup.list.unchecked.markdown", { fg = green })
a.nvim_set_hl(0, "@markup.list.checked.markdown", { fg = green })
