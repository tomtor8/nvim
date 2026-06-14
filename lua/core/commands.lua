local a = vim.api
local notify = require("user.notify-floating")

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

-- Toggle relative numbers {{{1
a.nvim_create_user_command("Togglerelnum", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
    -- Provide visual feedback
    local status = vim.opt.relativenumber:get() and "Enabled" or "Disabled"
    vim.api.nvim_echo({ { "Relative Number: " .. status, "None" } }, false, {})
end, { desc = "Toggle relative line numbers" })

-- Toggle wrap {{{1
a.nvim_create_user_command("Togglewrap", function()
    -- Toggle both options
    vim.opt.wrap = not vim.opt.wrap:get()
    vim.opt.linebreak = not vim.opt.linebreak:get()
    -- Provide feedback
    local status = vim.opt.wrap:get() and "Enabled" or "Disabled"
    vim.api.nvim_echo({ { "Wrap/Linebreak: " .. status, "None" } }, false, {})
end, { desc = "Toggle visual line wrapping and line breaking" })

-- Custom :Sort {{{1
-- Custom :Sort command that works for selection or the whole file
a.nvim_create_user_command("Sort", function(opts)
    local range = (opts.range == 2) and "'<,'>" or "%"
    vim.cmd(range .. "!sort " .. opts.args)
end, {
    nargs = "*",
    range = true, -- This allows the command to accept a range
    desc = "Sort selection or buffer using system sort",
})

-- Custom Formatters {{{1
local formatters = {
    sh = "shfmt -i 4 -w %",
    bash = "shfmt -i 4 -w %",
    css = "prettier --write %",
    html = "prettier --write %",
    fish = "fish_indent -w %",
    lua = "stylua --indent-type=Spaces --indent-width=4 --quote-style=AutoPreferDouble --column-width=80 %",
    python = "ruff format %",
    javascript = "prettier --write %",
    markdown = "prettier --write %",
    json = "prettier --write %",
    toml = "tombi format %",
    -- Use a function for LSP-based formatting
    rust = function()
        vim.lsp.buf.format({ async = false })
    end,
}

vim.api.nvim_create_user_command("Format", function()
    local ft = vim.bo.filetype
    local formatter = formatters[ft]

    if type(formatter) == "function" then
        formatter()
    elseif type(formatter) == "string" then
        -- 1. Save if there are unsaved changes so the external tool sees them
        if vim.bo.modified then
            vim.cmd("write")
        end
        -- 2. Run the external formatter
        vim.cmd("!" .. formatter)
        -- 3. Reload the buffer from disk to show the formatted result
        vim.cmd("edit!")
        -- 4. Move the cursor back to where it was (optional but nice)
        vim.cmd("normal! G''")
    else
        notify.notify_floating(
            "No formatter defined for " .. ft,
            "Apply Format"
        )
    end
end, { desc = "Format current buffer based on filetype" })

-- Remove trailing whitespaces {{{1

vim.api.nvim_create_user_command("WhiteEnd", function(opts)
    -- Save the current cursor position to prevent it from jumping
    local save_cursor = vim.fn.getpos(".")
    local range = opts.range > 0
            and string.format("%d,%d", opts.line1, opts.line2)
        or "%"
    -- Run the substitution string safely using Lua's raw string syntax
    vim.cmd(string.format([[%ss/\s\+$//e]], range))
    -- Restore the cursor position
    safe_restore_cursor(save_cursor)
end, {
    range = true, -- Allows the command to accept a range (e.g., visual selection)
    desc = "Remove trailing white space in a file or selection",
})

-- Remove excess whitespace between words {{{1

vim.api.nvim_create_user_command("WhiteInter", function(opts)
    -- Save the current cursor position to prevent it from jumping
    local save_cursor = vim.fn.getpos(".")
    local range = opts.range > 0
            and string.format("%d,%d", opts.line1, opts.line2)
        or "%"
    vim.cmd(string.format([[%ss/\v\S\zs\s+\ze\S/ /ge]], range))
    -- Restore the cursor position
    safe_restore_cursor(save_cursor)
end, {
    range = true, -- Allows the command to accept a range (e.g., visual selection)
    desc = "Remove white spaces between words in a file or selection",
})

-- Import Lua template {{{1
a.nvim_create_user_command("Luatemp", function()
    -- :0r reads the file and inserts it starting at line 0
    -- G moves the cursor to the end of the file
    vim.cmd("0r /home/tom/Templates/lua/basic.lua")
    vim.cmd("normal! G")
end, { desc = "Import basic Lua template at the start of the buffer" })

-- Close all buffers except active {{{1
vim.cmd.cnoreabbrev("Bo", "BufOnly")
vim.api.nvim_create_user_command("BufOnly", function(args)
    local confirm = vim.o.confirm
    vim.o.confirm = true
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf then
            pcall(vim.api.nvim_buf_delete, buf, { force = args.bang })
        end
    end
    vim.o.confirm = confirm
end, { bang = true })

-- Macro Selector with optional Number argument {{{1
-- You can repeat the macro N times
local labeled_macros = {
    { label = "Wrap word in quotes", macro = 'viw"zc""<Esc>P' },
    { label = "Append trailing comma", macro = "A,<Esc>j" },
    {
        label = "QuoteBlock from line blank line",
        macro = "I> _<Esc>A_  <Esc>jddI> <Esc>jI><Esc>j",
    },
    {
        label = "QuoteBlock from line line line",
        macro = "I> _<Esc>A_  <Esc>jI> <Esc>o<Esc>j",
    },
    {
        label = "Definition List from line line line",
        macro = "jI: <Esc>o<Esc>j",
    },
    {
        label = "Definition List from line blank line",
        macro = "jddI: <Esc>jj",
    },
}

-- Define the command with nargs = '?' to allow 0 or 1 argument
vim.api.nvim_create_user_command("MacroSelect", function(opts)
    -- Parse the argument as a number; default to 1 if empty or invalid
    local count = tonumber(opts.args) or 1
    -- vim.ui.select(items, opts, on_choice)
    vim.ui.select(labeled_macros, {
        prompt = string.format("Select a macro to run (%dx):", count),
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            -- Multiply the macro keystrokes by the count
            local full_macro = string.rep(choice.macro, count)
            local keys =
                vim.api.nvim_replace_termcodes(full_macro, true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
            notify.notify_floating(
                string.format("Executed: %s (%dx)", choice.label, count),
                "Execute Macro"
            )
        end
    end)
end, { nargs = "?" }) -- '?' means 0 or 1 argument

-- Macro Selector for a Range of Lines {{{1
-- use it in the Visual mode
-- or in Command mode e.g., `:15,20MacroSelectRange`
-- or :.,+5MacroSelectRange -> Runs on the current line plus 5 lines
-- or :%MacroSelectRange -> Runs on the entire file
local labeled_macros_for_range = {
    { label = "Append trailing comma", macro = "A,<Esc>" },
}

vim.api.nvim_create_user_command("MacroSelectRange", function(opts)
    -- opts.line1 and opts.line2 are automatically populated by the range
    local start_line = opts.line1
    local end_line = opts.line2

    vim.ui.select(labeled_macros_for_range, {
        prompt = string.format(
            "Run macro on lines %d-%d:",
            start_line,
            end_line
        ),
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            -- Format the raw macro string into executable terminal codes
            local macro_keys =
                vim.api.nvim_replace_termcodes(choice.macro, true, false, true)

            -- Loop through every line in the range
            for line = start_line, end_line do
                -- Move the cursor to the current line, column 0
                vim.api.nvim_win_set_cursor(0, { line, 0 })

                -- Run the macro keys on this specific line
                vim.api.nvim_feedkeys(macro_keys, "nx", false)
            end

            notify.notify_floating(
                string.format(
                    "Applied '%s' to lines %d through %d",
                    choice.label,
                    start_line,
                    end_line
                ),
                "Execute Macro for Range"
            )
        end
    end)
end, { range = true }) -- Enable range support

-- Bind to x mode (Visual Mode)
-- '<,>' automatically applies to the current visual selection
vim.keymap.set(
    "x",
    "<leader>m",
    ":MacroSelectRange<CR>",
    { desc = "Run macro on selected lines" }
)

-- Select Substitute Pattern {{{1
-- Define your list of pre-configured substitute patterns
-- Usage: `:SubSelect` on the current line
-- `:%SubSelect` or `:15,20Subselect` or on a range in visual mode
local labeled_subs = {
    { label = "Strip trailing whitespace", pattern = [[\s\+$]], replace = "" },
    {
        label = "Convert snake_case to camelCase",
        pattern = [[\v_([a-z])]],
        replace = [[\u\1]],
    },
    {
        label = "Wrap word in quotes (simple)",
        pattern = [[\v(\w+)]],
        replace = [["\1"]],
    },
    {
        label = "Replace **E|I|O..** with `E|I..`",
        pattern = [[\v\*\*(E|I|IE|UE|O|U)\*\*]],
        replace = [[`\1`]],
    },
    {
        label = [[Replace **\-text** with `-text`]],
        pattern = [[\v\*\*\\(-.{-})\*\*]],
        replace = [[`\1`]],
    },
}

vim.api.nvim_create_user_command("SubSelect", function(opts)
    -- Grab the range boundaries provided by the user command
    local start_line = opts.line1
    local end_line = opts.line2

    vim.ui.select(labeled_subs, {
        prompt = string.format(
            "Apply substitution on lines %d-%d:",
            start_line,
            end_line
        ),
        format_item = function(item)
            return string.format(
                "%s  ➔  (:s/%s/%s/)",
                item.label,
                item.pattern,
                item.replace
            )
        end,
    }, function(choice)
        if choice then
            -- Construct the classic Ex command: '<,>s/pattern/replace/g'
            -- We use 'g' for global (all occurrences on the line) and 'e' to suppress errors if no match is found
            local cmd = string.format(
                "%d,%ds/%s/%s/ge",
                start_line,
                end_line,
                choice.pattern,
                choice.replace
            )

            -- Safely execute the substitution
            local success, err = pcall(function()
                vim.cmd(cmd)
            end)

            if success then
                notify.notify_floating(
                    string.format(
                        "Applied: %s (Lines %d-%d)",
                        choice.label,
                        start_line,
                        end_line
                    ),
                    "Substitute"
                )
            else
                notify.notify_floating(
                    "Substitution failed: " .. tostring(err),
                    "Substitute"
                )
            end
        end
    end)
end, { range = true }) -- Crucial: enables range parsing (`%`, `.,+5`, visual selection)

-- Select Commands {{{1
-- Define your list of pre-configured substitute patterns
-- Usage: `:%CmdSelect` globally on the whole file
-- :CmdSelect works only on the cursor line
-- `:15,20CmdSelect` on a range or in visual mode
local labeled_cmds = {
    -- delete 2 lines to a black hole register `_`
    {
        label = "Remove lines containing combi",
        cmnd = [[g/\(^0%$\|^100%$\|^P$\|^P-I$\|^Lit\.$\|^S-I$\|^S-F$\|^FEM\)/.,+1d _]],
    },
    { label = "Remove lines containing `0%`", cmnd = [[g/^0%$/.,+1d _]] },
    { label = "Remove lines containing `100%`", cmnd = [[g/^100%$/.,+1d _]] },
    { label = "Remove lines containing `Lit.`", cmnd = [[g/^Lit\./.,+1d _]] },
    { label = "Remove lines containing `S-I`", cmnd = [[g/^S-I/.,+1d _]] },
    { label = "Remove lines containing `S-F`", cmnd = [[g/^S-F/.,+1d _]] },
    { label = "Remove lines containing `FEM`", cmnd = [[g/^FEM/.,+1d _]] },
    { label = "Remove lines containing `P`", cmnd = [[g/^P$/.,+1d _]] },
    { label = "Remove lines containing `P-I`", cmnd = [[g/^P-I/.,+1d _]] },
}

vim.api.nvim_create_user_command("CmdSelect", function(opts)
    -- Grab the range boundaries provided by the user command
    local start_line = opts.line1
    local end_line = opts.line2

    vim.ui.select(labeled_cmds, {
        prompt = string.format(
            "Apply command on lines %d-%d:",
            start_line,
            end_line
        ),
        format_item = function(item)
            return string.format("%s  ➔  (:%s)", item.label, item.cmnd)
        end,
    }, function(choice)
        if choice then
            -- construct the command
            local cmd =
                string.format("%d,%d%s", start_line, end_line, choice.cmnd)

            -- Safely execute the substitution
            local success, err = pcall(function()
                vim.cmd(cmd)
            end)

            if success then
                notify.notify_floating(
                    string.format(
                        "Applied: %s (Lines %d-%d)",
                        choice.label,
                        start_line,
                        end_line
                    ),
                    "Command"
                )
            else
                notify.notify_floating(
                    "Command failed: " .. tostring(err),
                    "Command"
                )
            end
        end
    end)
end, { range = true }) -- Crucial: enables range parsing (`%`, `.,+5`, visual selection)

-- Load Macros to a selected register {{{1
-- optional argument is the register, can be any alphabet key
-- usage `:MacroLoad` loads the choice to @q - default
-- `:MacroLoad b` loads the choice to @b and so on...
local labeled_macros_to_load = {
    { label = "Bold to InLineCode", macro = [[lBxr`f*xr`]] },
    { label = "Underline text with ---", macro = [[yyp<c-v>$r-]] },
    { label = "Wrap text in ---", macro = [[yyp<c-v>$r-yykP]] },
    { label = "Wrap text in BOX", macro = [[I| <Esc>A |<Esc>yyp<c-v>$r-yykP]] },
    { label = "Append trailing comma", macro = "A,<Esc>" },
    { label = "Bold Word", macro = 'viW"zc**<Esc>pa**<Esc>' },
    { label = "Italic Word", macro = 'viW"zc__<Esc>P' },
    { label = "Inline Code Word", macro = 'viW"zc``<Esc>P' },
    { label = "Definition List line line line", macro = "jI: <Esc>o<Esc>j" },
    { label = "Wrap word in quotes", macro = 'viw"zc""<Esc>P' },
    {
        label = "BlockQuote line line line",
        macro = "I> _<Esc>A_  <Esc>jI> <Esc>o<Esc>j",
    },
    {
        label = "BlockQuote line blank line",
        macro = "I> _<Esc>A_  <Esc>jddI> <Esc>jj",
    },
}

vim.api.nvim_create_user_command("MacroLoad", function(opts)
    local reg = "q"
    if opts.args and opts.args ~= "" then
        reg = string.sub(opts.args, 1, 1):lower()
    end

    if not string.match(reg, "^[a-z]$") then
        notify.notify_floating(
            "Error: Target must be a valid register between a and z.",
            "Error"
        )
        return
    end

    vim.ui.select(labeled_macros_to_load, {
        prompt = string.format("Load macro into register '@%s':", reg),
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            -- CONVERSION STEP: Translate "<Esc>" strings into true internal keystroke codes
            local clean_macro =
                vim.api.nvim_replace_termcodes(choice.macro, true, false, true)

            -- Load the translated binary string into the register
            vim.fn.setreg(reg, clean_macro)
            notify.notify_floating(
                string.format("Loaded '%s' into @%s", choice.label, reg),
                "Load Macro"
            )
        end
    end)
end, { nargs = "?" })

-- Remove Blank Lines with optional range {{{1
-- default is the entire file
-- uses global command `:<range>g/^$/d`
vim.api.nvim_create_user_command("RemoveBlankLines", function(opts)
    local start_line = opts.line1
    local end_line = opts.line2
    local cmd = string.format([[%d,%dg/^$/d]], start_line, end_line)

    -- Wrapped in an anonymous function to satisfy the LSP type analyzer
    pcall(function()
        vim.cmd(cmd)
    end)

    notify.notify_floating(
        string.format(
            "Cleared blank lines from range %d-%d",
            start_line,
            end_line
        ),
        "Remove Blank Lines"
    )
end, {
    range = "%",
    desc = "Remove empty lines in a given range or the whole file",
})

-- Convert hex colors to rgb or rgba or vice versa {{{1
-- accepts ranges, e.g., %, 1,5 and so on. default runs on a single line
-- Custom Neovim command to convert hex colors to rgb/rgba
a.nvim_create_user_command("Hex2Rgb", function(opts)
    -- Get the line range from the command context
    local start_line = opts.line1 - 1
    local end_line = opts.line2

    -- Grab the lines from the buffer
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

    -- Helper function to convert a hex pair to an integer
    local function hex_to_dec(hex)
        return tonumber(hex, 16)
    end -- <-- Fixed missing 'end' here

    -- Helper function to convert alpha hex to a rounded decimal string
    local function alpha_to_dec(hex)
        local dec = tonumber(hex, 16) / 255
        return string.format("%.2f", dec):gsub("%.?0+$", "")
    end

    -- Loop through each line and apply the substitution
    for i, line in ipairs(lines) do
        -- Match 8-character hex codes (#rrggbbaa)
        line = line:gsub("#(%x%x)(%x%x)(%x%x)(%x%x)", function(r, g, b, alpha)
            return string.format(
                "rgba(%d, %d, %d, %s)",
                hex_to_dec(r),
                hex_to_dec(g),
                hex_to_dec(b),
                alpha_to_dec(alpha)
            )
        end)

        -- Match 6-character hex codes (#rrggbb)
        line = line:gsub("#(%x%x)(%x%x)(%x%x)", function(r, g, b)
            return string.format(
                "rgb(%d, %d, %d)",
                hex_to_dec(r),
                hex_to_dec(g),
                hex_to_dec(b)
            )
        end)

        lines[i] = line
    end

    -- Write the modified lines back to the buffer
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end, {
    range = true,
    desc = "Convert #rrggbb and #rrggbbaa colors to rgb/rgba",
})

-- Custom Neovim command to convert rgb/rgba colors to hex
a.nvim_create_user_command("Rgb2Hex", function(opts)
    -- Get the line range from the command context
    local start_line = opts.line1 - 1
    local end_line = opts.line2

    -- Grab the lines from the buffer
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

    -- Helper function to convert an alpha decimal (e.g., 0.5) to a 2-character hex string
    local function alpha_to_hex(alpha_str)
        local alpha = tonumber(alpha_str)
        if not alpha then
            return "ff"
        end
        -- Scale 0.0-1.0 to 0-255, then round it properly
        local dec = math.floor(alpha * 255 + 0.5)
        return string.format("%02x", dec)
    end

    -- Loop through each line and apply the substitution
    for i, line in ipairs(lines) do
        -- 1. Match rgba(%d, %d, %d, %f) format (handles spaces and decimals safely)
        -- This matches digits, spaces, commas, periods, and trailing alpha values
        line = line:gsub(
            "rgba?%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*([%d%.]+)%s*%)",
            function(r, g, b, alp)
                local r_hex = string.format("%02x", tonumber(r))
                local g_hex = string.format("%02x", tonumber(g))
                local b_hex = string.format("%02x", tonumber(b))
                local a_hex = alpha_to_hex(alp)
                return "#" .. r_hex .. g_hex .. b_hex .. a_hex
            end
        )

        -- 2. Match standard rgb(%d, %d, %d) format
        line = line:gsub(
            "rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)",
            function(r, g, b)
                local r_hex = string.format("%02x", tonumber(r))
                local g_hex = string.format("%02x", tonumber(g))
                local b_hex = string.format("%02x", tonumber(b))
                return "#" .. r_hex .. g_hex .. b_hex
            end
        )

        lines[i] = line
    end

    -- Write the modified lines back to the buffer
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end, {
    range = true,
    desc = "Convert rgb(...) and rgba(...) colors to #rrggbb and #rrggbbaa",
})
