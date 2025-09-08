-- https://github.com/ibhagwan/smartyank.nvim
-- 在"dd"等不希望将内容复制到系统剪贴板的时候不复制到系统剪贴板。支持在SSH等情况复制到系统剪贴板
-- Copy yanked text to system clipboard (regardless of clipboard setting)
-- If tmux is available, copy to a tmux clipboard buffer (enables history)
-- If ssh session is detected, use OSC52 to copy to the terminal host clipboard
return {
	"ibhagwan/smartyank.nvim",
	event = { "BufRead", "BufNewFile" },
	opts = function()
		require("smartyank").setup({})
	end,
}
