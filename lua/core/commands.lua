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
    local range = opts.range > 0 and string.format("%d,%d", opts.line1, opts.line2) or "%"
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
    local range = opts.range > 0 and string.format("%d,%d", opts.line1, opts.line2) or "%"
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
