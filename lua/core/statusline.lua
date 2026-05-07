-- Helper to get current Git branch {{{1
local function get_git_status()
    local branch = vim.b.gitsigns_head
    if branch then
        return string.format(" %%#StatusGit# %s%%#StatusLine# ", branch)
    end

    -- findfile can return a string or a list depending on flags
    local head_path =
        vim.fn.findfile(".git/HEAD", vim.fn.expand("%:p:h") .. ";")

    -- Ensure it's a non-empty string
    if type(head_path) ~= "string" or head_path == "" then
        return ""
    end

    local f = io.open(head_path, "r")
    if not f then
        return ""
    end

    local content = f:read("*l")
    f:close()

    if content then
        local name = content:match("ref: refs/heads/(.+)")
        if name then
            return string.format(" %%#StatusGit# %s%%#StatusLine# ", name)
        end
    end
    return ""
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
local lsp_icons = {
    lua_ls = "󰢱",
    basedpyright = "󱔎",
    filepaths_ls = "󰈔",
    html = "󰌝",
    cssls = "󰌜",
    fish_lsp = "󰈺",
    bash_ls = "󱆃",
    rust_analyzer = "󱘗",
}

local function get_lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        return ""
    end

    local icons = {}
    for _, client in ipairs(clients) do
        local icon = lsp_icons[client.name] or client.name
        table.insert(icons, icon)
    end

    local client_display = table.concat(icons, " ")
    -- Logic for vim.lsp.status() removed here to stop log-like info

    return string.format(" %%#StatusLspName#%s %%#StatusLine# ", client_display)
end

-- Main statusline function {{{1
function _G.simple_statusline()
    local mode_info = mode_map[vim.api.nvim_get_mode().mode] or mode_map["n"]
    local current_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

    local ok, s_info =
        pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
    local search = ""
    if
        ok
        and s_info
        and s_info.total
        and s_info.total > 0
        and vim.v.hlsearch ~= 0
    then
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
