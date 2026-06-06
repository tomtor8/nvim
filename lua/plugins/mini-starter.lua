local starter = require("mini.starter")
starter.setup({
    header = [[
┳┓  ┏┓  ┏┓  ┓┏  ┳  ┳┳┓
┃┃  ┣   ┃┃  ┃┃  ┃  ┃┃┃
┛┗  ┗┛  ┗┛  ┗┛  ┻  ┛ ┗
]],
    footer = "<C-c> exit MiniStarter!",
    items = {
        starter.sections.recent_files(4, false, false), -- number, current_dir, show_path
        {
            action = "lua vim.pack.update()",
            name = "Update Plugins",
            section = "Favorites",
        },
        {
            action = "e /home/tom/.config/niri/config.kdl",
            name = "Niri Config",
            section = "Favorites",
        },
        { action = "Pick files", name = "Files", section = "Pick" },
        { action = "Pick oldfiles", name = "Old Files", section = "Pick" },
        { action = "Pick grep_live", name = "Words", section = "Pick" },
        starter.sections.builtin_actions(),
        { action = "enew", name = "New Buffer", section = "Builtin actions" },
        -- { action = "qall!", name = "Quit Neovim", section = "Builtin actions" },
    },
    content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning("center", "center"),
    },
})
