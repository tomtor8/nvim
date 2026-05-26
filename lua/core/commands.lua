local a = vim.api

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
    lua = "stylua %",
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
        print("No formatter defined for " .. ft)
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
            print(string.format("Executed: %s (%dx)", choice.label, count))
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

            print(
                string.format(
                    "Applied '%s' to lines %d through %d",
                    choice.label,
                    start_line,
                    end_line
                )
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

-- Load Macros to a selected register {{{1
-- optional argument is the register, can be any alphabet key
-- usage `:MacroLoad` loads the choice to @q - default
-- `:MacroLoad b` loads the choice to @b and so on...
local labeled_macros_to_load = {
    { label = "Wrap word in quotes", macro = 'viw"zc""<Esc>P' },
    { label = "Append trailing comma", macro = "A,<Esc>" },
    { label = "Bold Word", macro = 'viW"zc**<Esc>pa**<Esc>' },
    { label = "Italic Word", macro = 'viW"zc__<Esc>P' },
    { label = "Inline Code Word", macro = 'viW"zc``<Esc>P' },
    { label = "Definition List line line line", macro = "jI: <Esc>o<Esc>j" },
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
        print("Error: Target must be a valid register between a and z.")
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
            print(string.format("Loaded '%s' into @%s", choice.label, reg))
        end
    end)
end, { nargs = "?" })

-- Remove Blank Lines with optional range {{{1
-- default is the entire file
-- uses global command `:<range>g/^$/d`
vim.api.nvim_create_user_command("RemoveBlankLines", function(opts)
    local original_cursor = vim.api.nvim_win_get_cursor(0)

    local start_line = opts.line1
    local end_line = opts.line2

    local cmd = string.format([[%d,%dg/^$/d]], start_line, end_line)

    -- Wrapped in an anonymous function to satisfy the LSP type analyzer
    pcall(function()
        vim.cmd(cmd)
    end)

    pcall(vim.api.nvim_win_set_cursor, 0, original_cursor)

    print(
        string.format(
            "Cleared blank lines from range %d-%d",
            start_line,
            end_line
        )
    )
end, {
    range = "%",
    desc = "Remove empty lines in a given range or the whole file",
})
