-- https://github.com/andymass/vim-matchup
-- 它需要你知道vim在normal模式下的%有什么作用
-- 基于treesitter在光标位置将if..else if..else等语言内的对应标签高亮, 扩展%键能力。
return {
	"andymass/vim-matchup",
	event = "UIEnter",
	opts = function()
		vim.g.matchup_matchparen_offscreen = {
			method = "popup",
		}
	end,
}
