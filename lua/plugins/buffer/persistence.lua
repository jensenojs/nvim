-- https://github.com/folke/persistence.nvim
-- 自动保存session到文件中, 在下次打开相同目录/项目时, 可以手动加载session恢复之前的工作状态。
local bind = require("utils.bind")
local map_callback = bind.map_callback

local keymaps = {
	["n|<leader>pc"] = map_callback(function()
			require("persistence").load()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("恢复当前目录下的session连接"),

	["n|<leader>pl"] = map_callback(function()
			require("persistence").load({
				last = true,
			})
		end)
		:with_noremap()
		:with_silent()
		:with_desc("恢复上一次session连接"),

	["n|<leader>px"] = map_callback(function()
			require("persistence").stop()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("这次的会话不要在退出时保存"),
}

bind.nvim_load_mapping(keymaps)

return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	config = true,
}
