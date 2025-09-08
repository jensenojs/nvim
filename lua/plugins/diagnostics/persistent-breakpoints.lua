-- https://github.com/Weissle/persistent-breakpoints.nvim
-- 在读取缓冲时加载并恢复断点
return {
	"Weissle/persistent-breakpoints.nvim",
	-- 确保在 BufReadPost 之前被加载, 这样插件的 autocmd 才能接收到 BufReadPost
	event = { "BufReadPre", "BufNewFile" },
	main = "persistent-breakpoints",
	opts = {
		load_breakpoints_event = { "BufReadPost" },
		-- 如使用会话类插件且断点未恢复, 可尝试启用
		always_reload = true,
	},
}


