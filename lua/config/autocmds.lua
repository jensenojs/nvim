--[[
 模块: config.autocmds

 意图:
   收敛全局自动命令, 统一触发时机与副作用范围。
   逻辑与正式版等价, 仅新增 im-select 可执行守卫与中文注释。

 注意:
   - 本模块零导出; 在 require 时注册 autocmd, 尽量保持幂等。
   - 依赖: 可选 config.env (存在则使用 env.has.im_select)
 ]]

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- 焦点返回/终端关闭/离开终端时执行 checktime
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	command = "checktime",
})

-- 输入法: 从插入模式切回普通/可视时切换到英文
-- 说明: 仅在系统存在 im-select 时注册, 避免无意义系统调用
local ok_env, env = pcall(require, "config.environment")
if ok_env and env.has.im_select then
	vim.api.nvim_create_autocmd({ "ModeChanged" }, {
		pattern = "i:n,i:v",
		group = augroup("im-select"),
		callback = function()
			local result = vim.fn.system("im-select")
			if not string.find(result, "com.apple.keylayout.ABC") then
				vim.fn.system("im-select com.apple.keylayout.ABC")
			end
		end,
	})
end

-- 文本被 yank 后高亮
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- 窗口尺寸变化时等比分屏
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- 特定 FileType 下按 q 关闭窗口
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"grug-far",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- 文本类文件自动换行与拼写检查
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.opt_local.conceallevel = 2
		vim.opt_local.formatoptions:remove({ "o", "t" })
	end,
})

-- 保存前自动创建目录
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- 修复通过 telescope 打开的文件无法折叠的问题
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = { "*" },
	command = "normal zx",
})
