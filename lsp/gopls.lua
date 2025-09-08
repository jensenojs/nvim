-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/gopls.lua
-- lsp/gopls.lua
-- https://go.dev/gopls/features/passive#semantic-tokens
-- Minimal, pragmatic defaults for gopls
return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod" },
	root_markers = {
		".golangci.yml",
		".golangci.yaml",
		".golangci.toml",
		".golangci.json",
		"go.work",
		"go.mod",
		".git",
	},
	settings = {
		gopls = {
			-- documentHighlight = true,
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
			matcher = "fuzzy",
			symbolMatcher = "fuzzy",
			completeUnimported = true,
			analyses = {
				unusedparams = true,
				unreachable = true,
				shadow = true,
				nilness = true,
				unusedwrite = true,
			},
			codelenses = {
				generate = true, -- show the `go generate` lens.
				gc_details = true, --  // Show a code lens toggling the display of gc's choices.
				test = true,
				tidy = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			directoryFilters = { "-node_modules" },
		},
	},
}
