-- 1. Clear existing highlights and set the theme name
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.g.colors_name = "tokyonight"

-- 2. Centralized Color Palette (Tokyo Night Spec)
local colors = {
    bg = "#1a1b26", -- Main background
    fg = "#c0caf5", -- Text
    fold = "#565f89", -- Muted gray-blue
    panel = "#1f2335", -- Darker background for floating panels/menus
    border = "#15161e", -- Dark boundary tone
    comment = "#565f89", -- Comment color
    gutter = "#3b4261", -- Line numbers / borders
    non_text = "#414868", -- Inactive/hidden markers
    pmenu_fg = "#a9b1d6", -- Secondary text
    visual_bg = "#33467c", -- Selection background
    -- Accent Colors
    yellow = "#e0af68", -- Yellow
    light_yellow = "#e0af68", -- Used for markdown formatting
    orange = "#ff9e64", -- Orange
    dark_orange = "#db4b4b", -- Warm warning tint
    red = "#f7768e", -- Neon red/pink
    light_red = "#ff7a93", -- Lighter pink accent
    purple = "#bb9af7", -- Violet/Purple
    lavender = "#9d7cd8", -- Muted Purple
    blue = "#7aa2f7", -- Bright Blue
    cyan = "#7dcfff", -- Cyan / Light Blue
    green = "#9ece6a", -- Green
    lime = "#73daca", -- Teal/Aqua tone
    mint = "#1abc9c", -- Mint/Torquoise
}

-- 3. Base Highlights (Core UI and Syntax styling)
local base_highlights = {
    Comment = { fg = colors.comment, italic = true },
    Constant = { fg = colors.orange },
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
    Special = { fg = colors.cyan },
    Statement = { fg = colors.purple, bold = true }, -- Tokyo Night uses purple for conditionals/statements
    String = { fg = colors.green },
    TabSeparator = { fg = colors.border, bg = colors.bg },
    TodoLabel = { fg = colors.bg, bg = colors.lime, bold = true },
    Visual = { bg = colors.visual_bg },

    -- Statusline components
    StatusCommand = { fg = colors.bg, bg = colors.purple, bold = true },
    StatusInsert = { fg = colors.bg, bg = colors.blue, bold = true },
    StatusError = { fg = colors.red, bg = "none", bold = true },
    StatusGit = { fg = colors.comment, italic = false },
    StatusLine = { fg = colors.pmenu_fg, bg = colors.panel },
    StatusLspName = { fg = colors.comment, bg = "none", italic = false },
    StatusNormal = { fg = colors.bg, bg = colors.green, bold = true },
    StatusReplace = { fg = colors.bg, bg = colors.orange, bold = true },
    StatusVisual = {
        fg = colors.bg,
        bg = colors.magenta or colors.purple,
        bold = true,
    },
    StatusWarn = { fg = colors.yellow, bg = "none", bold = true },

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
    }, -- Tokyo Night defaults to blue/orange accents for headings
    ["@markup.heading.2.markdown"] = {
        fg = colors.red,
        bg = colors.border,
        bold = true,
    },
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
    ["@markup.italic"] = { fg = colors.yellow, italic = true },
    ["@markup.strong"] = { fg = colors.orange, bold = true },
    ["@markup.raw.markdown_inline"] = { fg = colors.green, bg = colors.border },
    ["@markup.raw.block.markdown"] = { fg = colors.fg, bg = "none" },
    ["@markup.list.markdown"] = { fg = colors.blue },
    -- tables
    ["@markup.heading.markdown"] = { fg = colors.blue, bold = true },
    -- punctuation / dots, dashes, brackets
    ["@punctuation.special.markdown"] = { fg = colors.gutter },
    -- links, images
    ["@markup.link.markdown_inline"] = { fg = colors.cyan },
    ["@markup.link.label.markdown_inline"] = {
        fg = colors.cyan,
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
