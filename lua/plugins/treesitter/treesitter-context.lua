return {
	-- nvim-treesitter-context: https://github.com/nvim-treesitter/nvim-treesitter-context
	-- 设计意图: 在窗口顶部固定当前作用域(类/函数/方法等)的上下文头部, 辅助大文件/深缩进下的定位。
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		enable = true,
		throttle = true,
		max_lines = 0, -- 0 表示不限制高度
		patterns = {
			default = { "class", "function", "method" },
		},
	},
}
