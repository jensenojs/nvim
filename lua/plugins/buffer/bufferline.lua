-- https://github.com/akinsho/bufferline.nvim
-- 缓冲区/标签栏。使用 tabs 模式模拟原生 tabline
-- https://github.com/roobert/bufferline-cycle-windowless.nvim
-- 需要么? 还是算了
return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	main = "bufferline",
	opts = function()
		local icons = require("utils.icons").get("ui")
		return {
			options = {
				number = nil,
				modified_icon = icons.Modified,
				buffer_close_icon = icons.Close,
				left_trunc_marker = icons.Left,
				right_trunc_marker = icons.Right,
				max_name_length = 20,
				max_prefix_length = 13,
				tab_size = 20,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				enforce_regular_tabs = false,
				persist_buffer_sort = true,
				always_show_bufferline = true,
				separator_style = "slope",

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
			},
		}
	end,
}
