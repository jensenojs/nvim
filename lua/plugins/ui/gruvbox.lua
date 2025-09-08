-- https://github.com/ellisonleao/gruvbox.nvim
-- 主题不应懒加载以避免启动时闪烁
return {
	"ellisonleao/gruvbox.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		transparent_mode = false,
	},
	config = function(_, opts)
		require("gruvbox").setup(opts)
		vim.cmd.colorscheme("gruvbox")
	end,
}
