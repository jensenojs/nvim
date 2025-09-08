-- consider https://github.com/MeanderingProgrammer/render-markdown.nvim
-- https://github.com/OXY2DEV/markview.nvim
-- 一个轻量的markdown预览器
-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	event = "BufRead *.md", -- 只在打开markdown文件时加载
	-- lazy = false,
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = function()
		local presets = require("markview.presets")
		return {
			checkboxes = presets.checkboxes.nerd,
			markdown = {
				horizontal_rules = presets.thin,
				tables = presets.double,
				headings = presets.glow_center,
			},
		}
	end,
	keys = {
		{
			"<leader><leader>m",
			"<Cmd>Markview toggle<CR>",
			desc = "toggle markdown preview",
			mode = "n",
			noremap = true,
			silent = true,
		},
	},
}
