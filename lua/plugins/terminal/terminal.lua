-- https://github.com/akinsho/toggleterm.nvim
-- 终端集成: 懒加载 + 浮动面板 + btop 专用切换
local btop_term
local qwen_term

-- 使用 config.environment 中统一的可执行文件检查
local env = require("config.environment")

-- 通知用户缺少命令
local function notify_missing_command(cmd)
	vim.notify(
		"命令 '" .. cmd .. "' 未找到，请确保它已安装并在 PATH 中。",
		vim.log.levels.WARN,
		{ title = "Terminal" }
	)
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	-- 按键触发将自动懒加载插件
	keys = {
		-- 也可在此补充更多触发键位
		{
			"<c-s-p>",
			function()
				local cmd = "btop"
				if not env.has.btop then
					notify_missing_command(cmd)
					return
				end

				local ok, mod = pcall(require, "toggleterm.terminal")
				if not ok then
					return
				end
				local Terminal = mod.Terminal
				if not btop_term then
					btop_term = Terminal:new({
						cmd = cmd,
						hidden = true,
						direction = "float",
						float_opts = { border = "double" },
					})
				end
				btop_term:toggle()
			end,
			desc = "查看btop",
			mode = "n",
		},
		{
			"<c-s-q>",
			function()
				local cmd = "qwen"
				if not env.has.qwen then
					notify_missing_command(cmd)
					return
				end

				local ok, mod = pcall(require, "toggleterm.terminal")
				if not ok then
					return
				end
				local Terminal = mod.Terminal
				if not qwen_term then
					qwen_term = Terminal:new({
						cmd = cmd,
						hidden = true,
						direction = "float",
						float_opts = { border = "double" },
					})
				end
				qwen_term:toggle()
			end,
			desc = "打开qwen",
			mode = "n",
		},
	},
	main = "toggleterm",
	opts = {
		open_mapping = "<c-\\>",
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
