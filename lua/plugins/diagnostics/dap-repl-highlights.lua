-- https://github.com/LiadOz/nvim-dap-repl-highlights
-- DAP REPL语法高亮插件配置
return {
	"LiadOz/nvim-dap-repl-highlights",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	opts = function()
		require("nvim-dap-repl-highlights").setup()
	end,
	-- lazy = true,
	-- opts = true,
}
