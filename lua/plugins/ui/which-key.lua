-- https://github.com/folke/which-key.nvim
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	main = "which-key",
	opts = {
		plugins = {
			marks = true,
			registers = true,
			spelling = {
				enabled = true,
				suggestions = 20,
			},
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
			},
		},
		icons = {
			breadcrumb = "›",
			separator = "➜",
			group = "+",
		},
		win = {
			border = "rounded",
		},
		layout = {
			align = "left",
		},
		show_help = true,
		-- 使用 which-key v3 的 spec 声明顶层分组, 便于维护
		spec = {
			{
				"<leader>a",
				group = "Ai",
			},
			{
				"<leader>d",
				group = "dap",
			},
			{
				"<leader>l",
				group = "lsp",
			},
			{
				"<leader>g",
				group = "git",
			},
			{
				"<leader>p",
				group = "persistence",
			},
			{
				"<leader>m",
				group = "bookmarks",
			},
			{
				-- "<leader>Y",
				-- group = "Yazi"
			},
		},
	},
}
