-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

-- leader键设置为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--  按下 Home 键时, 会回到该行第一个非空白字符处; 再次按 Home, 又会跳转到行首.
local function home()
	local head = (vim.api.nvim_get_current_line():find("[^%s]") or 1) - 1
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[2] = cursor[2] == head and 0 or head
	vim.api.nvim_win_set_cursor(0, cursor)
end

-- 智能关闭当前 buffer: 若只剩一个已列出 buffer 则直接退出
local function close_or_quit()
	local listed = vim.fn.getbufinfo({
		buflisted = 1,
	})
	if #listed <= 1 then
		-- 尊重修改状态: 使用 confirm 给予保存/放弃的确认
		vim.cmd("confirm qa")
	else
		vim.cmd("bd")
	end
end

local function copy_relative_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return
	end -- 不是具体文件，静默返回
	local rel = vim.fn.fnamemodify(name, ":~:.")
	vim.fn.setreg("+", rel) -- 写入系统剪贴板
end

-- 复制绝对路径到系统剪贴板
local function copy_absolute_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return
	end
	local abs = vim.fn.fnamemodify(name, ":p") -- 取完整绝对路径
	vim.fn.setreg("+", abs)
end

-- :ShowKey  ——  调试任意按键的原始/修饰符
local function show_key()
	-- 清掉多余的 hit-enter 提示
	vim.cmd('echo ""')
	-- 让用户按一次键（不映射、不超时）
	local ok, key = pcall(vim.fn.getcharstr)
	if not ok then
		return
	end -- 用户 <Esc>/Ctrl-C 取消
	local mod = vim.fn.getcharmod() -- 修饰符位掩码
	local byte = vim.fn.char2nr(key) -- Unicode 码位

	-- 位掩码解释
	local mods = {}
	if mod == 0 then
		mods[#mods + 1] = "none"
	else
		if bit.band(mod, 1) ~= 0 then
			mods[#mods + 1] = "Shift"
		end
		if bit.band(mod, 2) ~= 0 then
			mods[#mods + 1] = "Alt"
		end
		if bit.band(mod, 4) ~= 0 then
			mods[#mods + 1] = "Ctrl"
		end
		if bit.band(mod, 8) ~= 0 then
			mods[#mods + 1] = "Super"
		end
	end

	-- 拼成人类可读
	local desc = table.concat(mods, "+")
	if #mods > 0 and key ~= "" then
		desc = desc .. "+"
	end
	desc = desc .. (key == " " and "Space" or key)

	-- 如果支持 CSI-u，也给出对应序列
	local csiu = ""
	if byte > 0 then
		csiu = string.format("  CSI-u: \\x1b[%d;%du", byte, mod == 0 and 1 or mod + 1)
	end

	-- 一次性打印
	vim.api.nvim_echo({
		{ "Raw key: ", "Question" },
		{ string.format("%q", key), "String" },
		{ "  |  code=", "Comment" },
		{ tostring(byte), "Number" },
		{ "  mod=", "Comment" },
		{ tostring(mod), "Number" },
		{ "  |  ", "Comment" },
		{ desc, "Identifier" },
		{ csiu, "Comment" },
	}, false, {})
end

-- 注册成 Ex 命令
vim.api.nvim_create_user_command("ShowKey", show_key, { desc = "Show raw key/modifier info" })

-- 利用bind的辅助函数封装了vim.keymap.系列的函数
local keymaps = {

	-----------------
	--  增强搜索   --
	-----------------
	["n|n"] = map_callback(function()
			local cw = vim.fn.expand("<cword>") -- 光标下的单词
			if cw == "" then
				return
			end -- 空行啥也不干
			vim.fn.setreg("/", "\\<" .. cw .. "\\>") -- 整词匹配，去掉 \\< \\> 可部
			vim.cmd("normal! n") -- 沿用系统搜索逻辑
		end)
		:with_noremap()
		:with_silent()
		:with_desc("向下找当前光标所在单词"),
	["n|N"] = map_callback(function()
			local cw = vim.fn.expand("<cword>")
			if cw == "" then
				return
			end
			vim.fn.setreg("/", "\\<" .. cw .. "\\>")
			vim.cmd("normal! N")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("向上找当前光标所在单词"),

	-----------------
	--  缓冲区管理   --
	-----------------

	--
	["n|<s-l>"] = map_cr("bnext"):with_noremap():with_silent():with_desc("切换到下一个buffer"),
	["n|<s-h>"] = map_cr("bprevious"):with_noremap():with_silent():with_desc("切换到上一个buffer"),

	-- ["n|<c-s-t>"] = map_cmd("<C-w>j"):with_noremap():with_silent():with_desc("打开上一个关闭的文件"),
	-- 用插件来做这个功能

	-----------------
	--  窗口管理   --
	-----------------
	["n|<c-s-l>"] = map_cmd("<C-w>l"):with_noremap():with_silent():with_desc("窗口:光标向右移动"),
	["n|<c-s-h>"] = map_cmd("<C-w>h"):with_noremap():with_silent():with_desc("窗口:光标向左移动"),
	["n|<c-s-k>"] = map_cmd("<C-w>k"):with_noremap():with_silent():with_desc("窗口:光标向上移动"),
	["n|<c-s-j>"] = map_cmd("<C-w>j"):with_noremap():with_silent():with_desc("窗口:光标向下移动"),

	-----------------
	--   保存与退出  --
	-----------------
	["n|<leader>q"] = map_callback(close_or_quit)
		:with_noremap()
		:with_silent()
		:with_desc("删除当前buffer/若为最后一个则退出"),
	["n|<leader>w"] = map_cr("w"):with_noremap():with_silent():with_desc("保存当前buffer"),
	["n|<leader>W"] = map_cr("wa"):with_noremap():with_silent():with_desc("保存所有的buffer"),
	["n|<leader>Q"] = map_cr("qa"):with_noremap():with_silent():with_desc("强制退出neovim"),

	-----------------
	--    可视模式  --
	-----------------
	["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):with_desc("可视:Move this line down"),
	["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):with_desc("可视:Move this line up"),
	["v|<"] = map_cmd("<gv"):with_noremap():with_silent():with_desc("重新选择上一次选择的区域"),
	["v|>"] = map_cmd(">gv")
		:with_noremap()
		:with_silent()
		:with_desc("重新选择上一次选择的区域, 并向右移动一次缩进"),

	-- 触发 quick_substitute 的执行
	-- ["v|<leader>ss"] = map_callback(function()
	--     require("utils.quick_substitute").run()
	-- end):with_noremap():with_silent():with_desc("在指定行间进行文本替换"),

	-----------------
	--    其他      --
	-----------------
	["in|<Home>"] = map_callback(home):with_desc("光标:先按相当于^, 再按到行首"),
	["n|0"] = map_callback(home):with_desc("光标:先按相当于^, 再按到行首"),
	["n|<c-y>"] = map_callback(copy_relative_path)
		:with_noremap()
		:with_desc()
		:with_desc("拷贝当前文件的相对路径"),
	["n|<c-s-y>"] = map_callback(copy_absolute_path)
		:with_noremap()
		:with_desc()
		:with_desc("拷贝当前文件的绝对路径"),

	-----------------
	--  标签页管理(不要用tab, 最好也不要用这个功能)   --
	-----------------
	-- ["n|<a-t>"] = map_cr("tabe"):with_noremap():with_silent():with_desc("标签:新建一个tab"),
	-- ["n|<a-c>"] = map_cmd(":tabc<CR>"):with_noremap():with_silent():with_desc("标签:关闭当前tab"),
	-- ["n|<a-o>"] = map_cmd(":tabo<CR>"):with_noremap():with_silent():with_desc(
	--     "标签:关闭除了当前tab以外的其他tab"),

	-- -- 之所以用这个奇怪的快捷键是想要让它低成本地在tmux中也能用...
	-- ["n|<a-s-l>"] = map_callback(function()
	--     -- 获取当前标签页的索引
	--     local current_tab = vim.fn.tabpagenr()
	--     -- 获取标签页总数
	--     local total_tabs = vim.fn.tabpagenr("$")
	--     -- 如果当前标签页不是最左边的标签页, 则向左移动
	--     if current_tab < total_tabs then
	--         vim.cmd("tabnext")
	--     else
	--         -- 否则跳转回开始
	--         vim.cmd("tabfirst")
	--     end
	-- end):with_noremap():with_silent():with_desc("标签:移动到右tab"),

	-- ["n|<a-s-h>"] = map_callback(function()
	--     -- 获取当前标签页的索引
	--     local current_tab = vim.fn.tabpagenr()
	--     -- 获取标签页总数
	--     local total_tabs = vim.fn.tabpagenr("$")
	--     -- 如果当前标签页不是最右边的标签页, 则向右移动
	--     if current_tab > 1 then
	--         vim.cmd("tabprevious")
	--     else
	--         -- 否则跳转回最后
	--         vim.cmd("tablast")
	--     end
	-- end):with_noremap():with_silent():with_desc("标签:移动到左tab"),
}

bind.nvim_load_mapping(keymaps)

require("config.quick_substitute").setup({})

-----------------
--  LSP 相关    --
-----------------

-- 禁用 Neovim 内置的全局 LSP 键位映射
-- 这些映射在 Neovim 启动时就已定义 (:h lsp-defaults)
pcall(vim.keymap.del, "n", "grn") -- Rename
pcall(vim.keymap.del, "n", "gra") -- Code Action
pcall(vim.keymap.del, "x", "gra") -- Code Action
pcall(vim.keymap.del, "n", "grr") -- References
pcall(vim.keymap.del, "n", "gri") -- Implementation
pcall(vim.keymap.del, "n", "grt") -- Type Definition
pcall(vim.keymap.del, "n", "gO") -- Document Symbol, will use <leader>o instead
pcall(vim.keymap.del, "n", "<C-S>") -- Signature Help in Insert mode, will use <c-k> instead
