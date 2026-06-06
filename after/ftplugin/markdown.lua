-- for markdown snippets work
-- link the original snippets/markdown.json to
-- nvim/snippets/markdown.json and
-- nvim/snippets/markdown_inline.json
require("core.accented-char-maps").setup()

-- Buffer-local settings {{{1

local o = vim.opt_local
local a = vim.api
local k = vim.keymap
o.wrap = true
o.linebreak = true
o.cpoptions:append("n")
o.conceallevel = 3 -- hide some markdown characters
---- concealcursor = "n" does not expand the hidden parts
o.concealcursor = "n"

-- Keymaps {{{1

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

-- Helper function to safely restore cursor position without out-of-bounds jumps
local function safe_restore_cursor(saved_pos)
    vim.fn.setpos(".", saved_pos)
    local current_line = vim.api.nvim_get_current_line()
    -- saved_pos[3] is the column index
    if saved_pos[3] > #current_line then
        saved_pos[3] = math.max(1, #current_line)
        vim.fn.setpos(".", saved_pos)
    end
end

-- Data table holding the specific configuration for each command
local markdown_commands = {
    RemoveBold = {
        pattern = [[\*\*\(.\{-}\)\*\*]],
        replace = [[\1]],
        desc = "Remove bold markers",
    },
    RemoveItalic = {
        -- FIX: Added lookahead/lookbehind to ensure we don't touch double asterisks
        pattern = [[_\(.\{-}\)_]],
        replace = [[\1]],
        desc = "Remove italic markers `_italic_`",
    },
    RemoveInlineCode = {
        pattern = [[`\([^`]\{-}\)`]],
        replace = [[\1]],
        desc = "Remove inline code backticks",
    },
}

-- Loop through the configuration table to dynamically build the user commands
for command_name, config in pairs(markdown_commands) do
    a.nvim_buf_create_user_command(0, command_name, function(opts)
        local save_cursor = vim.fn.getpos(".")
        local range = opts.range > 0
                and string.format("%d,%d", opts.line1, opts.line2)
            or "%"

        -- Construct and execute the substitute command dynamically
        local cmd_string = string.format(
            [[%ss/%s/%s/ge]],
            range,
            config.pattern,
            config.replace
        )
        vim.cmd(cmd_string)

        safe_restore_cursor(save_cursor)
    end, { range = true, desc = config.desc })
end

-- Create blockquote from alternating lines {{{2
-- takes integer / number of repetition argument
vim.api.nvim_create_user_command("FmToQuote", function(opts)
    -- Default to 1 repetition if no argument is provided
    local count = 1
    local appendix = ""

    -- Check if an argument was passed and try to convert it to a number
    if opts.args ~= "" then
        local parsed_count = tonumber(opts.args)
        if parsed_count then
            count = parsed_count
        else
            vim.notify("Argument must be an integer", vim.log.levels.ERROR)
            return
        end
    end

    if count > 1 then
        appendix = "I><Esc>j"
    end

    -- Define your complex set of motions here
    -- 'A;<Esc>j' appends a semicolon, exits insert mode, and moves down one line
    -- we use nvim_replace_termcodes so special keys like <Esc> are parsed correctly
    local motions = vim.api.nvim_replace_termcodes(
        "I> _<Esc>A_  <Esc>jddI> <Esc>j" .. appendix,
        true,
        false,
        true
    )

    -- Run the motions 'count' times
    for _ = 1, count do
        -- Use nvim_feedkeys with the 'n' flag to simulate 'normal!' (ignores mappings)
        -- and the 'x' flag to execute synchronously before looping again
        vim.api.nvim_feedkeys(motions, "nx", false)
    end

    if count > 1 then
        -- cleanup the last trailing >
        vim.api.nvim_feedkeys("kx", "nx", false)
    end
end, {
    nargs = "?", -- Accepts 0 or 1 argument
    desc = "Format lines with alternating empty lines to blockquote.",
})
