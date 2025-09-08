-- https://github.com/mikavilpas/yazi.nvim
return {
	"mikavilpas/yazi.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
		"MagicDuck/grug-far.nvim",
	},
	opts = function()
		-- Example: when using the `copy_relative_path_to_selected_files` key (default
		-- <c-y>) in yazi, change the way the relative path is resolved.
		require("yazi").setup({
			integrations = {
				-- https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/copy-relative-path-to-files.md
				resolve_relative_path_implementation = function(args, get_relative_path)
					-- By default, the path is resolved from the file/dir yazi was focused on
					-- when it was opened. Here, we change it to resolve the path from
					-- Neovim's current working directory (cwd) to the target_file.
					local cwd = vim.fn.getcwd()
					local path = get_relative_path({
						selected_file = args.selected_file,
						source_dir = cwd,
					})
					return path
				end,
			},
			open_for_directories = false,
			-- 	keymaps = {
			-- 		show_help = "<f1>",
			-- 	},
		})
	end,
	keys = {
		{
			"<leader>y",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Yazi : Open yazi at the current file",
		},
		-- no need for open in the current working directory
		{
			"<leader>Y",
			mode = { "n", "v" },
			"<cmd>Yazi cwd<cr>",
			desc = "Yazi : Open yazi at the current working space",
		},
	},
}
