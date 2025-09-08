return {
	-- nvim-treesitter-textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	-- 设计意图: 本文件独立负责 textobjects 的功能选项与键位, 遵循“一插件一文件”。
	"nvim-treesitter/nvim-treesitter-textobjects",
	event = "VeryLazy",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	main = "nvim-treesitter.configs",
	opts = {
		textobjects = {
			-- 语义选择
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer", -- 选中函数(外部)
					["if"] = "@function.inner", -- 选中函数(内部)
					["ac"] = "@class.outer", -- 选中类(外部)
					["ic"] = { query = "@class.inner", desc = "选中类的内部区域" },
					["as"] = { query = "@scope", query_group = "locals", desc = "选中语言作用域(scope)" },
					["id"] = "@conditional.inner", -- 选中条件(内部)
					["ad"] = "@conditional.outer", -- 选中条件(外部)
				},
				selection_modes = {
					["@parameter.outer"] = "v", -- 按字符
					["@function.outer"] = "V", -- 按行
					["@class.outer"] = "<c-v>", -- 按块
				},
				include_surrounding_whitespace = false,
			},
			-- 语义跳转
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = { query = "@class.outer", desc = "跳到下一个类的开始处" },
					["]o"] = "@loop.*",
					["]s"] = { query = "@scope", query_group = "locals", desc = "跳到下一个作用域(scope)" },
					["]z"] = { query = "@fold", query_group = "folds", desc = "跳到下一个折叠区域" },
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer", -- 跳到下一个类的结尾处
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
				goto_next = { ["]d"] = "@conditional.outer" }, -- 跳到下一个条件
				goto_previous = { ["[d"] = "@conditional.outer" }, -- 跳到上一个条件
			},
			-- 参数交换(默认关闭)
			swap = {
				enable = false,
				swap_next = { ["<leader>a"] = "@parameter.inner" },
				swap_previous = { ["<leader>A"] = "@parameter.inner" },
			},
		},
	},
}
