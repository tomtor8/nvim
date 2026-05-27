---@class NotifyFloating
---A module for creating custom, temporary floating notifications in Neovim.
local M = {}

-- Function to create a temporary floating notification
---@param msg string Message to display
---@param title string|nil Optional title of notification
---@return nil
function M.notify_floating(msg, title)
    -- Create an unlisted, scratch buffer (no file, auto-deleted)
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set the content of the buffer (expects a list of strings)
    local lines = {
        " " .. (title or "Notification") .. " ",
        "─" .. string.rep("─", #msg) .. "─",
        " " .. msg .. " ",
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Calculate dimensions based on text length
    local width = #msg + 2
    local height = #lines

    -- Define window configuration options
    local opts = {
        relative = "editor", -- Position relative to the entire editor screen
        row = 1, -- Top row
        col = vim.o.columns - width - 3, -- Align to the top-right corner
        width = width,
        height = height,
        style = "minimal", -- Removes line numbers, statusline, etc.
        border = "rounded", -- Clean, modern border style
        focusable = false, -- Prevent the cursor from entering the window
    }

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, false, opts)

    -- Highlight group for a subtle visual distinction (optional)

    -- Highlight group for a subtle visual distinction
    -- Modern API replacement for deprecated nvim_win_set_option
    vim.api.nvim_set_option_value(
        "winhl",
        "Normal:NormalFloat,FloatBorder:FloatBorder",
        { win = win }
    )

    -- Automatically close the notification after 5 seconds (5000 ms)
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, 5000)
end

return M
