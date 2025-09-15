--[[
  提供统一的环境感知能力, 包括平台检测、可执行文件检查、路径聚合等。
]]

local M = {}

local sys = vim.loop.os_uname().sysname
M.is_mac = sys == "Darwin"
M.is_linux = sys == "Linux"
M.is_windows = sys == "Windows_NT"
M.is_wsl = vim.fn.has("wsl") == 1

-- 可执行文件探测
local function has(exe)
	return vim.fn.executable(exe) == 1
end

M.has = {
	git = has("git"),
	rg = has("rg"),
	fd = has("fd") or has("fdfind"),
	nvr = has("nvr"),
	im_select = has("im-select"),
	btop = has("btop"),
	qwen = has("qwen"),
	opencode = has("opencode"),
	uv = has("uv"),
	python3 = has("python3"),
	-- 为Python虚拟环境中的python添加检查
	python_in_venv = function()
		local env = require("config.environment")
		for _, envkey in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
			local envdir = env[envkey]
			if envdir and envdir ~= "" then
				local p = envdir .. "/bin/python"
				if has(p) then
					return true
				end
			end
		end
		return false
	end,
}

-- 离线/最小模式
M.offline = tostring(vim.env.NVIM_OFFLINE or "") == "1"

M.minimal_mode = M.offline or not M.has.git

function M.summary()
	return string.format(
		"offline=%s, minimal=%s, has(git=%s, rg=%s, fd=%s, nvr=%s, im-select=%s, btop=%s, qwen=%s, opencode=%s, uv=%s, python3=%s)",
		tostring(M.offline),
		tostring(M.minimal_mode),
		tostring(M.has.git),
		tostring(M.has.rg),
		tostring(M.has.fd),
		tostring(M.has.nvr),
		tostring(M.has.im_select),
		tostring(M.has.btop),
		tostring(M.has.qwen),
		tostring(M.has.opencode),
		tostring(M.has.uv),
		tostring(M.has.python3)
	)
end

local function compute()
	local t = {}
	t.is_mac = M.is_mac
	t.is_linux = M.is_linux
	t.is_windows = M.is_windows
	t.is_wsl = M.is_wsl
	t.vim_path = vim.fn.stdpath("config")
	local path_sep = t.is_windows and "\\" or "/"
	local home = t.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
	t.cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
	t.modules_dir = t.vim_path .. path_sep .. "modules"
	t.home = home
	t.data_dir = string.format("%s/site/", vim.fn.stdpath("data"))
	-- 添加对 Python 环境变量的访问
	t.virtual_env = os.getenv("VIRTUAL_ENV")
	t.conda_prefix = os.getenv("CONDA_PREFIX")
	-- 添加对 PIP 代理的访问
	t.pip_proxy = os.getenv("PIP_PROXY")
	return t
end

local data = compute()

setmetatable(M, {
	__index = function(_, k)
		-- 对于函数类型的 has 项，需要特殊处理
		if k == "has" then
			return M.has
		end
		return data[k]
	end,
	__newindex = function(_, k, _)
		error(
			string.format(
				"config.environment is read-only (attempt to write key '%s'). Use local variables.",
				tostring(k)
			),
			2
		)
	end,
	__metatable = false,
})

-- Clipboard setup
-- https://tao.zz.ac/vim/vim-copy-over-ssh.html
if M.is_mac then
	vim.g.clipboard = {
		name = "macOS-clipboard",
		copy = {
			["+"] = "pbcopy",
			["*"] = "pbcopy",
		},
		paste = {
			["+"] = "pbpaste",
			["*"] = "pbpaste",
		},
		cache_enabled = 0,
	}
end

if M.is_wsl then
	vim.g.clipboard = {
		name = "win32yank-wsl",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
		cache_enabled = 0,
	}
end

-- https://www.reddit.com/r/neovim/comments/17oy2cv/why_can_i_successfully_transfer_clipboard/
-- https://github.com/tmux/tmux/wiki/Clipboard
if vim.env.TMUX then
	vim.g.clipboard = {
		name = "tmux-clipboard",
		copy = {
			["+"] = { "tmux", "load-buffer", "-w", "-" },
		},
		paste = {
			["+"] = { "tmux", "save-buffer", "-" },
		},
		cache_enabled = true,
	}
end

return M
