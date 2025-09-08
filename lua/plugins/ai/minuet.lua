-- https://github.com/milanglacier/minuet-ai.nvim
local env = require("config.environment")
if env.offline then
	return {}
end

return {
	"milanglacier/minuet-ai.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
	event = "InsertEnter",
	opts = function()
		require("minuet").setup({
			virtualtext = {
				auto_trigger_ft = { "go", "c", "cpp", "python", "rust", "sql" },
				keymap = {
					accept = "<A-y>",
					-- accept_line = '<A-a>',
					-- accept_n_lines = '<A-z>',
					next = "<A-]>",
					prev = "<A-[>",
					dismiss = "<A-e>",
				},
			},

			-- Default values
			provider = "codestral",

			-- Default values
			-- Whether show virtual text suggestion when the completion menu
			-- (nvim-cmp or blink-cmp) is visible.
			show_on_completion_menu = false,
		})
	end,
}
