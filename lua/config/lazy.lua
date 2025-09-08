-- config/lazy.lua
-- 作用: 在 tmp 环境中引导与配置 lazy.nvim, 并从 tmp/lua/plugins/** 导入插件规格
-- 特性: 该文件为自包含实现, 不依赖用户主配置
-- 1) lazy.nvim 引导
-- lazypath 为 lazy.nvim 的本地安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- 解释: vim.opt.rtp:prepend(lazypath)
--  - vim.opt 是 Neovim 0.7+ 提供的选项 API, 比如 vim.opt.number = true
--  - rtp 是 'runtimepath' 选项(可通过 :h 'runtimepath' 查看), 决定运行时搜寻脚本/插件的路径列表
--  - :prepend() 会把 lazypath 放到 runtimepath 列表的最前面, 确保 `require("lazy")` 能被解析到
--  - 等价于: vim.o.runtimepath = lazypath .. "," .. vim.o.runtimepath, 但 API 写法更安全直观
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then
	vim.schedule(function()
		vim.notify("加载 lazy.nvim 失败", vim.log.levels.ERROR, {
			title = "config.lazy",
		})
	end)
	return
end

-- 2) UI 图标: 兼容旧版 icons 配置
local icons = {}
do
	local ok_icons, mod = pcall(require, "utils.icons")
	if ok_icons then
		icons = {
			kind = mod.get("kind"),
			documents = mod.get("documents"),
			ui = mod.get("ui"),
			ui_sep = mod.get("ui", true),
			misc = mod.get("misc"),
		}
	end
end

local tmp_root = vim.fn.stdpath("data") .. "/lazy-tmp"

-- 3) 配置 lazy.nvim
-- 核心: 注入 Mason bin 目录到 PATH, 确保 Neovim 能找到 LSP 可执行文件
local function prepend_env_path(p)
	if p and #p > 0 and not string.find(vim.env.PATH or "", p, 1, true) then
		vim.env.PATH = p .. ":" .. (vim.env.PATH or "")
	end
end
prepend_env_path(vim.fn.stdpath("data") .. "/mason/bin")

lazy.setup({
	-- 使用 spec 导入, 自动递归加载 lua/plugins/** 中的模块文件
	-- 这样无需一个一个显式 require, 目录下新增/拆分文件会被自动发现
	spec = {
		{
			import = "plugins.mason",
		}, --  mason, 用来安装lsp 和 dap等
		{
			import = "plugins.ai",
		}, -- AI 相关子目录
		{
			import = "plugins.completion",
		}, -- 自动补全
		{
			import = "plugins.cursor",
		}, -- 光标移动相关
		{
			import = "plugins.diagnostics",
		}, -- 诊断相关
		{
			import = "plugins.file",
		}, -- 文件/检索/预览/大文件
		{
			import = "plugins.format",
		}, -- 格式化
		{
			import = "plugins.fuzzy_finder.telescope",
		}, -- 模糊查找
		{
			import = "plugins.git",
		}, -- Git 相关
		{
			import = "plugins.input",
		}, -- 输入法
		{
			import = "plugins.lang",
		}, -- 特定语言增强
		{
			import = "plugins.buffer",
		}, -- 缓冲区管理(标签页,持久化)
		{ import = "plugins.tasks" },        -- 任务管理
		{
			import = "plugins.terminal",
		}, -- 终端
		{ import = "plugins.test" },      -- 测试
		{
			import = "plugins.treesitter",
		}, -- 语法高亮相关
		{
			import = "plugins.ui",
		}, -- UI 美化相关
	},
}, {
	ui = {
		border = "rounded",
		icons = (next(icons) and {
			cmd = icons.misc and icons.misc.Code or "",
			config = icons.ui and icons.ui.Gear or "",
			event = icons.kind and icons.kind.Event or "",
			ft = icons.documents and icons.documents.Files or "",
			init = icons.misc and icons.misc.ManUp or "",
			import = icons.documents and icons.documents.Import or "",
			keys = icons.ui and icons.ui.Keyboard or "",
			loaded = icons.ui and icons.ui.Check or "",
			not_loaded = icons.misc and icons.misc.Ghost or "",
			plugin = icons.ui and icons.ui.Package or "",
			runtime = icons.misc and icons.misc.Vim or "",
			source = icons.kind and icons.kind.StaticMethod or "ﴑ",
			start = icons.ui and icons.ui.Play or "",
			list = icons.ui_sep and {
				icons.ui_sep.BigCircle,
				icons.ui_sep.BigUnfilledCircle,
				icons.ui_sep.Square,
				icons.ui_sep.ChevronRight,
			} or { "●", "○", "■", ">" },
		}) or nil,
	},
	change_detection = {
		notify = false,
	},
	-- 使用 tmp 独立根目录与锁文件, 避免污染主配置
	root = tmp_root,
	lockfile = tmp_root .. "/lazy-lock.json",
})
