return {
	-- nvim-treesitter-textsubjects: https://github.com/RRethy/nvim-treesitter-textsubjects
	-- 设计意图: 基于光标位置的启发式语义选择(textsubjects), 降低记忆特定对象名的负担, 与 textobjects 互补。
	"RRethy/nvim-treesitter-textsubjects",
	keys = { ".", "g;", "gi;" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	main = "nvim-treesitter.configs",
	opts = {
		textsubjects = {
			enable = true,
			prev_selection = ",",
			keymaps = {
				["."] = "textsubjects-smart",
				-- [";"] = "textsubjects-container-outer",
				-- ["i;"] = "textsubjects-container-inner",
				-- 方案A: 避免与 textobjects 的 `;`/`,` 可重复移动冲突
				["g;"] = "textsubjects-container-outer",
				["gi;"] = "textsubjects-container-inner",
			},
		},
	},
}
