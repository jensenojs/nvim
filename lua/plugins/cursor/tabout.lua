-- https://github.com/abecodes/tabout.nvim
-- 在Insert模式下, 按<Tab>可以跳出括号
-- Lua
return {
	"abecodes/tabout.nvim",
	lazy = false,
	-- events = { "BufReadPost", "BufNewFile" },
	config = function()
		-- opts = function()
		require("tabout").setup({
			tabkey = "", -- we drive <Plug>(Tabout) from blink.cmp; don't map <Tab> directly here
			backwards_tabkey = "", -- same for <S-Tab>
			act_as_tab = true, -- shift content if tab out is not possible
			act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
			default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
			default_shift_tab = "<C-d>", -- reverse shift default action,
			enable_backwards = true, -- well ...
			completion = true, -- integrate with completion menu
			tabouts = {
				{
					open = "'",
					close = "'",
				},
				{
					open = '"',
					close = '"',
				},
				{
					open = "`",
					close = "`",
				},
				{
					open = "(",
					close = ")",
				},
				{
					open = "[",
					close = "]",
				},
				{
					open = "{",
					close = "}",
				},
			},
			ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
			exclude = {}, -- tabout will ignore these filetypes
		})
	end,
	-- dependencies = { -- These are optional
	-- 	"nvim-treesitter/nvim-treesitter",
	-- },
	opt = true, -- Set this to true if the plugin is optional
	event = "InsertCharPre", -- Set the event to 'InsertCharPre' for better compatibility
	priority = 1000,
}
