-- 作用: LSP 运行时初始化
-- 注意: 此文件仅处理 LSP 的核心初始化, 不涉及插件增强 (如 blink.cmp, telescope 等)
-- LSP bootstrap autocommands group (idempotent and discoverable)
-- 全局 LSP 命令
local api, lsp, diagnostic = vim.api, vim.lsp, vim.diagnostic

local LSP_BOOTSTRAP = vim.api.nvim_create_augroup("lsp.bootstrap", {
	clear = true,
})

local ui = {
	border = "rounded", -- 圆角
	zindex = 50, -- 保证在普通浮动窗口之上
	max_width = math.floor(vim.o.columns * 0.8),
	max_height = math.floor(vim.o.lines * 0.7),
}

lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, ui)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, ui)

diagnostic.config({
	float = vim.tbl_extend("force", ui, {
		header = "💡 诊断",
		source = "if_many",
	}),
	virtual_text = {
		prefix = '●',
		spacing = 4,
		source = "if_many",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})

api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {
	desc = "Alias to `:checkhealth vim.lsp`",
})

api.nvim_create_user_command("LspLog", function()
	vim.cmd(string.format("tabnew %s", lsp.get_log_path()))
end, {
	desc = "Opens the Nvim LSP client log.",
})

local function complete_server(arg)
	local ok, servers = pcall(require, "config.lsp.enable-list")
	if not ok or type(servers) ~= "table" then
		return {}
	end
	local items = {}
	for _, name in ipairs(servers) do
		if name:sub(1, #arg) == arg then
			table.insert(items, name)
		end
	end
	return items
end

api.nvim_create_user_command("LspRestart", function(info)
	local ok_list, servers = pcall(require, "config.lsp.enable-list")
	servers = ok_list and servers or {}
	local whitelist = {}
	for _, s in ipairs(servers) do
		whitelist[s] = true
	end

	local targets = info.fargs
	for _, name in ipairs(targets) do
		if not whitelist[name] then
			vim.notify(("Invalid server name '%s'"):format(name), vim.log.levels.WARN, {
				title = "LspRestart",
			})
		else
			local ok_disable = pcall(vim.lsp.enable, name, false)
			if not ok_disable then
				for _, c in
					ipairs(vim.lsp.get_clients({
						name = name,
					}))
				do
					pcall(c.stop, c, true)
				end
			end
		end
	end

	vim.defer_fn(function()
		for _, name in ipairs(targets) do
			pcall(vim.lsp.enable, name)
		end
	end, 500)
end, {
	desc = "Restart the given client(s)",
	nargs = "+",
	complete = complete_server,
})

-- 在 Neovim 完全启动后启用 LSP 服务器
api.nvim_create_autocmd("FileType", {
	group = LSP_BOOTSTRAP,
	desc = "Enable configured LSP clients",
	callback = function()
		local servers = require("config.lsp.enable-list")
		for _, server_name in ipairs(servers) do
			vim.lsp.enable(server_name)
		end
	end,
})

-- 确保注册 LspAttach 相关自动命令与按键
local ok, mod = pcall(require, "config.lsp.attach")
if not ok then
	vim.notify("Failed to load config.lsp.attach", vim.log.levels.ERROR)
end
