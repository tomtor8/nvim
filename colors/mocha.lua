-- 1. Clear existing highlights and set the theme name
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.g.colors_name = "catppuccin-mocha"

-- 2. Centralized Color Palette (Catppuccin Mocha Spec)
local colors = {
    bg = "#0b0e14", -- Base
    fg = "#a6adc8", -- Text
    fold = "#6c7086", -- Overlay 0
    panel = "#181825", -- Mantle
    border = "#11111b", -- Crust
    comment = "#6c7086", -- Subtext 0
    gutter = "#45475a", -- Surface 1
    non_text = "#585b70", -- Surface 2
    pmenu_fg = "#bac2de", -- Subtext 1
    visual_bg = "#313244", -- Surface 0
    -- Accent Colors
    yellow = "#f9e2af", -- Yellow
    light_yellow = "#f5e0dc", -- Rosewater
    orange = "#fab387", -- Peach
    dark_orange = "#ef9f76", -- Maroon
    red = "#f38ba8", -- Red
    light_red = "#eba0ac", -- Flamingo
    purple = "#cba6f7", -- Mauve
    lavender = "#b4befe", -- Lavender
    blue = "#89b4fa", -- Blue
    cyan = "#89dceb", -- Sky
    green = "#a6e3a1", -- Green
    lime = "#b4befe", -- Light tone alternative (using Lavender for cohesive highlights)
    mint = "#94e2d5", -- Teal
}

-- 3. Base Highlights (Core UI and Syntax styling)
local base_highlights = {
    Comment = { fg = colors.comment, italic = true },
    Constant = { fg = colors.orange }, -- Catppuccin uses peach/orange for constants
    CursorLine = { bg = "none" },
    CursorLineNr = { fg = colors.yellow, bold = true, italic = true },
    FixmeLabel = { fg = colors.bg, bg = colors.red, bold = true },
    FloatBorder = { fg = colors.blue, bg = "none" },
    Folded = { fg = colors.fold, bg = "none", italic = true },
    Function = { fg = colors.blue },
    LineNr = { fg = colors.gutter, italic = true },
    MiniPickMatchCurrent = { fg = colors.yellow, bg = "none", bold = true },
    NonText = { fg = colors.non_text, italic = false },
    Normal = { fg = colors.fg, bg = "none" },
    NoteLabel = { fg = colors.bg, bg = colors.cyan, bold = true },
    Pmenu = { fg = colors.pmenu_fg, bg = "none" },
    PmenuSel = { fg = colors.yellow, bg = "none", bold = true },
    Search = { fg = colors.bg, bg = colors.yellow },
    Special = { fg = colors.light_yellow },
    Statement = { fg = colors.purple, bold = true }, -- Catppuccin uses mauve for keywords
    String = { fg = colors.green },
    TabSeparator = { fg = colors.border, bg = colors.bg },
    TodoLabel = { fg = colors.bg, bg = colors.mint, bold = true },
    Visual = { bg = colors.visual_bg },

    -- Statusline components
    StatusCommand = { fg = colors.bg, bg = colors.purple, bold = true },
    StatusInsert = { fg = colors.bg, bg = colors.blue, bold = true },
    StatusError = { fg = colors.light_red, bg = "none", bold = true },
    StatusGit = { fg = colors.comment, italic = false },
    StatusLine = { fg = colors.pmenu_fg, bg = colors.panel },
    StatusLspName = { fg = colors.comment, bg = "none", italic = false },
    StatusNormal = { fg = colors.bg, bg = colors.green, bold = true }, -- Swapped lime to native green for cleaner look
    StatusReplace = { fg = colors.bg, bg = colors.light_red, bold = true },
    StatusVisual = { fg = colors.bg, bg = colors.orange, bold = true },
    StatusWarn = { fg = colors.dark_orange, bg = "none", bold = true },

    -- Tabline components
    TabLine = { fg = colors.non_text, bg = colors.bg },
    TabLineSel = { fg = colors.bg, bg = colors.yellow, bold = true },

    -- Winbar components
    WinBar = { fg = colors.pmenu_fg, bg = colors.panel, bold = true },
    WinBarNC = { fg = colors.non_text, bg = colors.panel, italic = true },

    -- Markdown highlights
    ["@markup.heading.1.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
    ["@markup.heading.2.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    }, -- Catppuccin scales heading colors
    ["@markup.heading.3.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
    ["@markup.heading.4.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
    ["@markup.heading.5.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
    ["@markup.heading.6.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
    ["@markup.italic"] = { fg = colors.light_yellow, italic = true },
    ["@markup.strong"] = { fg = colors.orange, bold = true },
    ["@markup.raw.markdown_inline"] = { fg = colors.purple, bg = colors.border },
    ["@markup.raw.block.markdown"] = { fg = colors.fg, bg = "none" },
    ["@markup.list.markdown"] = { fg = colors.mint },
    -- tables
    ["@markup.heading.markdown"] = { fg = colors.blue, bold = true },
    -- punctuation / dots, dashes, brackets
    ["@punctuation.special.markdown"] = { fg = colors.gutter },
    -- links, images
    ["@markup.link.markdown_inline"] = { fg = colors.lavender },
    ["@markup.link.label.markdown_inline"] = {
        fg = colors.lavender,
        underline = true,
    },
    -- todos
    ["@markup.list.unchecked.markdown"] = { fg = colors.red },
    ["@markup.list.checked.markdown"] = { fg = colors.green },
}

-- 4. Highlight Links (DRY Aliases)
local links = {
    -- Native UI links
    NormalFloat = "Normal",
    -- Plugin links (Mini.nvim)
    MiniFilesCursorLine = "MiniPickMatchCurrent",
}

-- 5. Apply Base Highlights
for group, settings in pairs(base_highlights) do
    pcall(vim.api.nvim_set_hl, 0, group, settings)
end

-- 6. Apply Links
for group, target in pairs(links) do
    pcall(vim.api.nvim_set_hl, 0, group, { link = target })
end

-- 7. Transparency Configuration
local function transparent_background()
    local groups = {
        "EndOfBuffer",
        "NormalFloat",
        "SignColumn",
        "TabLineFill",
    }
    for _, group in ipairs(groups) do
        pcall(vim.api.nvim_set_hl, 0, group, { bg = "NONE" })
    end
end

transparent_background()
