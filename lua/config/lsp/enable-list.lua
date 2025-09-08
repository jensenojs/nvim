-- 服务清单 (The Server Manifest)
--
-- 一个简单的 Lua 表, 作为需要被管理的 LSP 服务的"清单"或"白名单"。
-- `bootstrap.lua` 会遍历此列表, 并为每个条目调用 `vim.lsp.enable()`。
-- 添加或移除一个服务器就像编辑这个列表一样简单。

return {
	-- "bashls",
	"clangd",
	"gopls",
	"golangci_lint_ls", -- 并行启动, 与 attach.lua 修复后的幂等逻辑兼容
	-- "jsonls",
	"lua_ls",
	"markdown_oxide",
	"ruff",
	"pyright",
	-- "rust_analyzer",  -- 由rustaceanvim插件管理
	-- "sqls",
	-- "vimls",
	-- "yamlls",
}
