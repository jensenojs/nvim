-- lsp/rust_analyzer.lua
-- Minimal, pragmatic defaults for rust-analyzer
return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	settings = {
		["rust-analyzer"] = {
			cargo = { allFeatures = true },
			check = { command = "clippy" },
			procMacro = { enable = true },
			inlayHints = {
				bindingModeHints = { enable = true },
				chainingHints = { enable = true },
				parameterHints = { enable = true },
				typeHints = { enable = true },
			},
		},
	},
}
