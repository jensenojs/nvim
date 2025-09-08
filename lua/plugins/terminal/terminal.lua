-- https://github.com/akinsho/toggleterm.nvim
-- 终端集成: 懒加载 + 浮动面板 + btop 专用切换
local btop_term
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	-- 按键触发将自动懒加载插件
	keys = {
		{
			"<c-s-p>",
			function()
				local ok, mod = pcall(require, "toggleterm.terminal")
				if not ok then
					return
				end
				local Terminal = mod.Terminal
				if not btop_term then
					btop_term = Terminal:new({
						cmd = "btop",
						hidden = true,
						direction = "float",
						float_opts = { border = "double" },
					})
				end
				btop_term:toggle()
			end,
			desc = "查看btop",
			mode = "n",
		}, -- 也可在此补充更多触发键位
	},
	main = "toggleterm",
	opts = {
		open_mapping = '<c-\\>',
		start_in_insert = true, -- 自动进入插入模式
		direction = "float", -- 浮动窗口
		autochdir = true, -- 跟随 Neovim 的当前工作目录
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {
				noremap = true,
				silent = true,
			})
		end,
	},
}
