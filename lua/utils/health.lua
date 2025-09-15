--[[
模块: utils.health (Kickstart 风格)

意图:
  提供轻量的健康检查入口, 便于 :checkhealth 或手动调用时快速判断环境是否就绪。
  采用与 kickstart.nvim 近似的单文件样式, 仅导出 M.check()。
]]
local M = {}

-- Backward-compatible aliases for Neovim < 0.10
local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error_ = vim.health.error or vim.health.report_error

local function has_any_exec(cmds)
	local list = type(cmds) == "table" and cmds or { cmds }
	for _, c in ipairs(list) do
		if vim.fn.executable(c) == 1 then
			return true, c
		end
	end
	return false, nil
end

-- Neovim 版本检查
local function check_neovim()
	local v = vim.version()
	local is_ok = (vim.fn.has("nvim-0.9") == 1) or (vim.fn.has("nvim-0.10") == 1)
	if is_ok then
		ok(string.format("Neovim >= 0.9 (current: %d.%d.%d)", v.major, v.minor, v.patch))
	else
		error_("Neovim >= 0.9 is required/recommended")
	end
end

-- 常见可执行文件检查(支持候选列表)
local function check_executables()
	local checks = {
		"git",
		"rg",
		{ "fd", "fdfind" },
		"lazygit",
		"nvr",
		"stylua",
		"selene",
		"shfmt",
		"black",
		"jq",
		"im-select",
		"delve",
		"btop",
		"qwen",
	}
	for _, item in ipairs(checks) do
		local ok_exec, chosen = has_any_exec(item)
		local label = type(item) == "table" and table.concat(item, "|") or item
		if ok_exec then
			ok(string.format("%s -> %s", label, chosen))
		else
			warn(string.format("missing %s", label))
		end
	end
end

-- 剪贴板专属检查
local function check_clipboard()
	local global = require("core.global")
	start("clipboard")

	-- 处于 tmux 会话: 期望由 tmux 接管剪贴板
	if vim.env.TMUX then
		local has_tmux = (vim.fn.executable("tmux") == 1)
		if has_tmux then
			ok("tmux executable found")
		else
			error_("tmux not found in PATH while $TMUX is set")
		end
		local gcb = vim.g.clipboard
		if type(gcb) == "table" and gcb.name == "tmux-clipboard" then
			ok("g:clipboard = tmux-clipboard (优先使用 tmux buffer)")
		else
			warn("g:clipboard 未设置为 tmux-clipboard, 请确保在 init.lua 早期调用 core.clipboard.setup()")
		end
		return
	end

	-- macOS: 期望 pbcopy/pbpaste 存在, 且 g:clipboard 被设置
	if global.is_mac then
		local has_pbcopy = (vim.fn.executable("pbcopy") == 1)
		local has_pbpaste = (vim.fn.executable("pbpaste") == 1)
		if has_pbcopy and has_pbpaste then
			ok("pbcopy/pbpaste detected")
		else
			error_("缺少 pbcopy/pbpaste, 请检查 macOS 系统工具是否可用")
		end
		local gcb = vim.g.clipboard
		if type(gcb) == "table" and gcb.name == "macOS-clipboard" then
			ok("g:clipboard = macOS-clipboard")
		else
			warn(
				"g:clipboard 未由 core.clipboard 设置为 macOS-clipboard, 请确认加载顺序(core.global -> core.clipboard)"
			)
		end
		return
	end

	-- WSL: 期望 win32yank.exe 可用
	if global.is_wsl then
		local has_win32yank = (vim.fn.executable("win32yank.exe") == 1)
		if has_win32yank then
			ok("win32yank.exe detected")
		else
			error_("缺少 win32yank.exe, 请将其加入 PATH 以桥接到 Windows 剪贴板")
		end
		local gcb = vim.g.clipboard
		if type(gcb) == "table" and gcb.name == "win32yank-wsl" then
			ok("g:clipboard = win32yank-wsl")
		else
			warn("g:clipboard 未由 core.clipboard 设置为 win32yank-wsl, 请确认加载顺序")
		end
		return
	end

	-- 其他 Linux: 本配置未强制覆盖, 建议安装系统工具
	local has_xclip = (vim.fn.executable("xclip") == 1)
	local has_xsel = (vim.fn.executable("xsel") == 1)
	local has_wlcopy = (vim.fn.executable("wl-copy") == 1)
	local has_wlpaste = (vim.fn.executable("wl-paste") == 1)
	if has_wlcopy and has_wlpaste then
		ok("wayland: wl-copy/wl-paste detected")
	elseif has_xclip or has_xsel then
		ok("x11: xclip/xsel detected")
	else
		warn(
			"未检测到常见的 Linux 剪贴板工具(xclip/xsel 或 wl-copy/wl-paste), 可手动设置 g:clipboard"
		)
	end

	-- 检查OSC-52支持
	local osc52_supported = vim.fn.has("clipboard_working") and vim.g.clipboard and vim.g.clipboard.name == "osc52"
	if osc52_supported then
		ok("OSC-52 clipboard supported (远程复制/粘贴)")
	elseif vim.env.SSH_CLIENT or vim.env.SSH_TTY then
		warn("远程会话中建议启用OSC-52: set g:clipboard to osc52 provider")
	end
end

-- blink.cmp/Rust 健康检查
function M.check_blink_cmp()
	start("blink.cmp")

	-- 1) 模块可用性
	local ok_mod = pcall(require, "blink.cmp")
	if ok_mod then
		ok("blink.cmp module is loadable")
	else
		warn("blink.cmp not installed or not loadable (skipping deeper checks)")
	end

	-- 2) Rust 工具链
	local has_cargo = (vim.fn.executable("cargo") == 1)
	local has_rustc = (vim.fn.executable("rustc") == 1)
	local has_rustup = (vim.fn.executable("rustup") == 1)

	if has_cargo then
		ok("cargo detected")
	else
		warn("missing cargo (Rust build unavailable)")
	end
	if has_rustup then
		ok("rustup detected")
	else
		warn("missing rustup (nightly management unavailable)")
	end

	if has_rustc then
		local out = vim.fn.systemlist({ "rustc", "--version" })
		local ver = type(out) == "table" and out[1] or nil
		if ver and ver:find("nightly") then
			ok("rustc nightly detected: " .. ver)
		elseif ver then
			warn("rustc nightly not detected: " .. ver .. " (blink.cmp Rust backend build may require nightly)")
		else
			ok("rustc detected")
		end
	else
		warn("missing rustc (falling back to Lua fuzzy)")
	end

	-- 3) 提示: 若需要强制 Rust
	--   在插件规格中设置 build = 'cargo +nightly build --release'
	--   并将 fuzzy.implementation = 'prefer_rust' 或 'rust'
end

function M.check()
	start("utils")
	check_neovim()
	check_executables()

	check_clipboard()
	check_blink_cmp()
end

return M
