-- https://github.com/LintaoAmons/scratch.nvim
-- Create temporary playground files effortlessly. Find them later without worrying about filenames or locations.
return {
	"LintaoAmons/scratch.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-telescope/telescope.nvim" }, -- optional: if you want to pick scratch file by telescope
	},

	keys = {
		{ "<c-s-n>", "<cmd>Scratch<cr>" },
		{ "<c-s-o>", "<cmd>ScratchOpen<cr>" },
	},

	opts = {
		file_picker = "telescope",
	},
}
