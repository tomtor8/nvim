-- General diagnostics settings {{{1
local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = 'rounded',
    source = true,
  },
  signs = {
    text = {
      [sev.ERROR] = " ",
      [sev.WARN]  = " ",
      [sev.INFO]  = " ",
      [sev.HINT]  = "󰌵 ",
    },
  },
})

-- Python {{{1
vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	settings = {
		basedpyright = {
			analysis = {
				diagnosticMode = "openFilesOnly",
				inlayHints = {
					callArgumentNames = true,
				},
			},
		},
	},
	root_dir = function(bufnr, on_dir)
		if not vim.fn.bufname(bufnr):match("%.txt$") then
			on_dir(vim.fn.getcwd())
		end
	end,
})

vim.lsp.enable("basedpyright")

-- Lua {{{1
-- 1. Define the config in a simple table
local lua_ls_config = {
	cmd = { "lua-language-server" },
	name = "lua_ls",
	-- root_dir = vim.fs.root(0, { ".git", "init.lua", ".luarc.json" }) or (vim.uv or vim.loop).cwd(),
	root_markers = { ".luarc.json", ".git", ".stylua.toml" },
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
				},
				checkThirdParty = false,
			},
		},
	},
}

-- 2. Use a "BufEnter" autocommand. This is the most aggressive trigger.
-- It runs every time you enter a buffer.
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.lua",
	callback = function()
		-- Directly start the client for the current buffer
		vim.lsp.start(lua_ls_config)
	end,
})

-- vim.lsp.config['lua_ls'] = {
--   cmd = { 'lua-language-server' },
--   filetypes = { 'lua' },
--   root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
-- }
--
-- vim.lsp.enable('lua_ls')

-- Rust {{{1
-- on Arch after sudo pacman -S rustup
-- run `rustup component add rust-analyzer` to install rust-analyzer
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	settings = {
		["rust-analyzer"] = {
			lens = {
				debug = { enable = true },
				enable = true,
				implementations = { enable = true },
			},
			diagnostics = { enable = true },
			references = {
				adt = { enable = true },
				enumVariant = { enable = true },
				method = { enable = true },
				trait = { enable = true },
			},
			run = { enable = true },
			updateTest = { enable = true },
		},
	},
})

vim.lsp.enable("rust_analyzer")

-- Fish {{{1

vim.lsp.config.fish_lsp = {
	cmd = { "fish-lsp", "start" },
	filetypes = { "fish" },
	root_markers = { ".git" },
}

-- 2. Enable it for automatic attachment
vim.lsp.enable("fish_lsp")

-- Bash {{{1
vim.lsp.config.bash_ls = {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = { ".git" },
	-- settings = {
	-- 	bashIde = {
	-- 		-- Dynamically point to the Mason binary
	-- 		shellcheckPath = "/home/tom/.local/share/nvim/mason/bin/shellcheck",
	-- 	},
	-- },
}

vim.lsp.enable("bash_ls")

-- CSS {{{1
-- Register the shim to silence the cssls error
vim.lsp.commands["editor.action.triggerSuggest"] = function(_, _) end

vim.lsp.config("cssls", {
	cmd = { "vscode-css-languageserver", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
	settings = {
		css = { validate = true },
		less = { validate = true },
		scss = { validate = true },
	},
})

-- 2. Enable it globally (Neovim will automatically start it for CSS files)
vim.lsp.enable("cssls")

-- HTML {{{1

vim.lsp.config("html", {
	cmd = { "vscode-html-languageserver", "--stdio" },
	filetypes = { "html" },
	root_markers = { "package.json", ".git" },
	init_options = {
		configurationSection = { "html", "css", "javascript" },
		embeddedLanguages = { css = true, javascript = true },
		provideFormatter = false,
	},
})

-- 2. Enable it globally (Neovim will automatically start it for CSS files)
vim.lsp.enable("html")

-- JSON {{{1

vim.lsp.config("jsonls", {
	cmd = { "vscode-json-languageserver", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	init_options = {
		provideFormatter = false,
	},
})

-- 2. Enable it globally (Neovim will automatically start it for CSS files)
vim.lsp.enable("jsonls")
