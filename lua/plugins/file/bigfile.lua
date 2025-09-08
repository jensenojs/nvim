-- https://github.com/LunarVim/bigfile.nvim
local ftdetect = {
	name = "ftdetect",
	opts = {
		defer = true,
	},
	disable = function()
		vim.api.nvim_set_option_value("filetype", "bigfile", {
			scope = "local",
		})
	end,
}

return {
	"LunarVim/bigfile.nvim",
	opts = function()
		require("bigfile").setup({
			filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
			pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
			features = { -- features to disable
				"indent_blankline",
				"illuminate",
				"lsp",
				"treesitter",
				"syntax",
				"matchparen",
				"vimopts",
				"filetype",
				ftdetect,
			},
		})
	end,
}
