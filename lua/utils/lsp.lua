-- lua/utils/lsp.lua
-- LSP 运行时辅助: 通知/可选加载/能力合并/可执行探测/条件启用
local M = {}

function M.notify_once(flag, msg, level)
	local key = "__lsp_bootstrap_notified_" .. flag
	if vim.g[key] then
		return
	end
	vim.g[key] = true
	vim.schedule(function()
		vim.notify(msg, level or vim.log.levels.WARN, {
			title = "lsp/utils",
		})
	end)
end

-- 检测任一可执行是否存在
function M.has_any_exec(cmds)
	local list = type(cmds) == "table" and cmds or { cmds }
	for _, c in ipairs(list) do
		if vim.fn.executable(c) == 1 then
			return true, c
		end
	end
	return false, nil
end

-- 若存在对应可执行文件则启用 LSP, 否则给出一次性温和提醒
function M.enable_if_present(server, opts)
	opts = opts or {}
	local ok_exec = true
	if opts.execs then
		ok_exec = M.has_any_exec(opts.execs)
	end
	if ok_exec then
		pcall(vim.lsp.enable, server)
	else
		local hint = opts.missing_hint or ("未检测到依赖, 已跳过自动启动: " .. server)
		M.notify_once("missing_exec_" .. server, hint, vim.log.levels.INFO)
	end
end

-- 检查LSP客户端是否支持某个方法
function M.if_support(method, bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, c in ipairs(clients) do
		if c:supports_method(method, bufnr) then
			return true
		end
	end
	return false
end

-- 检查buffer是否附加了LSP
function M.is_lsp_attached(bufnr)
	if not bufnr or type(bufnr) ~= "number" then
		return false
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	return clients and #clients > 0
end

return M
