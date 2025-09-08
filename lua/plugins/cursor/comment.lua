-- https://github.com/terrortylor/nvim-comment
-- 注释
local bind = require("utils.bind")

local map_cr = bind.map_cr
local keymaps = {
	-- For some reason, vim registers <C-/> as <C-_> (you can see it in insert mode using <C-v><C-/>). It can be the terminal or a historical design thing that terminal apps have to suffer.
	-- https://stackoverflow.com/questions/9051837/how-to-map-c-to-toggle-comments-in-vim
	["nv|<c-_>"] = map_cr(":CommentToggle"):with_noremap():with_silent():with_desc("注释/取消注释"),
	["nv|<c-/>"] = map_cr(":CommentToggle"):with_noremap():with_silent():with_desc("注释/取消注释"),
}

bind.nvim_load_mapping(keymaps)

return {
	"terrortylor/nvim-comment",
	config = function()
		-- Disable mappings
		require("nvim_comment").setup({
			create_mappings = false,
		})
	end,
}
