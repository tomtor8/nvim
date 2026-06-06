-- 1. Clear existing highlights and set the theme name
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "ayu-dark"

-- 2. Centralized Color Palette
local colors = {
  bg            = "#0B0E14",
  fg            = "#B3B1AD",
  fold          = "#5C6773",
  panel         = "#161922",
  border        = "#252B35",
  comment       = "#636A72",
  gutter        = "#454B55",
  non_text      = "#505662",
  pmenu_fg      = "#BFBDB6",
  visual_bg     = "#274364",
  -- Accent Colors
  yellow        = "#E6B450",
  light_yellow  = "#F1FA8C",
  orange        = "#F29668",
  dark_orange   = "#f29718",
  red           = "#FF3333",
  light_red     = "#F07178",
  purple        = "#A37ACC",
  lavender      = "#D2A6FF",
  blue          = "#55B4D4",
  cyan          = "#5CCFE6",
  green         = "#AAD94C",
  lime          = "#B8CC52",
  mint          = "#90dec5",
}

-- 3. Base Highlights (Core UI and Syntax styling)
local base_highlights = {
  Comment              = { fg = colors.comment, italic = true },
  Constant             = { fg = colors.lavender },
  CursorLine           = { bg = "none" },
  CursorLineNr         = { fg = colors.yellow, bold = true, italic = true },
  FixmeLabel           = { fg = colors.bg, bg = colors.red, bold = true },
  FloatBorder          = { fg = colors.blue, bg = "none" },
  Folded               = { fg = colors.fold, bg = "none", italic = true },
  Function             = { fg = colors.orange },
  LineNr               = { fg = colors.gutter, italic = true },
  MiniPickMatchCurrent = { fg = colors.yellow, bg = "none", bold = true },
  NonText              = { fg = colors.non_text, italic = false },
  Normal               = { fg = colors.fg, bg = "none" },
  NoteLabel            = { fg = colors.bg, bg = colors.cyan, bold = true },
  Pmenu                = { fg = colors.pmenu_fg, bg = "none" },
  PmenuSel             = { fg = colors.yellow, bg = "none", bold = true },
  Search               = { fg = colors.bg, bg = colors.yellow },
  Special              = { fg = colors.cyan },
  Statement            = { fg = colors.cyan, bold = true },
  String               = { fg = colors.green },
  TabSeparator         = { fg = colors.border, bg = colors.bg },
  TodoLabel            = { fg = colors.bg, bg = colors.mint, bold = true },
  Visual               = { bg = colors.visual_bg },

  -- Statusline components
  StatusCommand        = { fg = colors.bg, bg = colors.purple, bold = true },
  StatusInsert         = { fg = colors.bg, bg = colors.blue, bold = true },
  StatusError          = { fg = colors.light_red, bg = "none", bold = true },
  StatusGit            = { fg = colors.comment, italic = false },
  StatusLine           = { fg = colors.pmenu_fg, bg = colors.panel },
  StatusLspName        = { fg = colors.comment, bg = "none", italic = false },
  StatusNormal         = { fg = colors.bg, bg = colors.lime, bold = true },
  StatusReplace        = { fg = colors.bg, bg = colors.light_red, bold = true },
  StatusVisual         = { fg = colors.bg, bg = colors.orange, bold = true },
  StatusWarn           = { fg = colors.dark_orange, bg = "none", bold = true },

  -- Tabline compomnents
  TabLine              = { fg = colors.non_text, bg = colors.bg},
  TabLineSel           = { fg = colors.bg, bg = colors.yellow, bold = true },

  -- Winbar components
  WinBar               = { fg = colors.pmenu_fg, bg = colors.panel, bold = true },
  WinBarNC             = { fg = colors.non_text, bg = colors.panel, italic = true },

  -- Markdown highlights
  ["@markup.heading.1.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.heading.2.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.heading.3.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.heading.4.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.heading.5.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.heading.6.markdown"] = { fg = colors.light_red, bg = colors.border, bold = true },
  ["@markup.italic"] = { fg = colors.light_yellow, italic = true },
  ["@markup.strong"] = { fg = colors.yellow, bold = true },
  ["@markup.raw.markdown_inline"] = { fg = colors.purple, bg = colors.border },
  ["@markup.raw.block.markdown"] = { fg = colors.fg, bg = "none" },
  ["@markup.list.markdown"] = { fg = colors.mint },
  -- tables
  ["@markup.heading.markdown"] = { fg = colors.blue, bold = true },
  -- punctuation / dots, dashes, brackets
  ["@punctuation.special.markdown"] = { fg = colors.gutter },
  -- links, images
  ["@markup.link.markdown_inline"] = { fg = colors.lavender },
  ["@markup.link.label.markdown_inline"] = { fg = colors.lavender, underline = true },
  -- todos
  ["@markup.list.unchecked.markdown"] = { fg = colors.green },
  ["@markup.list.checked.markdown"] = { fg = colors.lime },
}

-- 4. Highlight Links (DRY Aliases)
local links = {
  -- Native UI links
  NormalFloat         = "Normal",
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
