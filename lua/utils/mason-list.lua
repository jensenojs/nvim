-- lua/utils/mason.lua
-- 分组维护 LSP servers 与工具, 提供聚合函数

local M = {}

-- 以语言/领域分组, servers 使用 lspconfig 的 Server 名, tools 使用 mason 包名
M.groups = {
	vim = {
		servers = { "vimls" },
		tools = { "vim-language-server" },
	},
	lua = {
		servers = { "lua_ls" },
		tools = { "stylua", "luacheck" },
	},
	go = {
		servers = { "gopls", "golangci_lint_ls" },
		tools = {
			"golangci-lint",
			"gofumpt",
			"gotests",
			"goimports",
			"gomodifytags",
			"impl",
			"go-debug-adapter",
			"delve",
		},
	},
	python = {
		servers = { "pyright" },
		tools = { "black", "pylint", "isort", "mypy", "ruff" },
	},
	c_cpp = {
		servers = { "clangd" },
		tools = { "cmake", "clang-format" },
	},
	rust = {
		servers = {}, -- 如需: { "rust_analyzer" }, 由 mrcjkb/rustaceanvim 接管
		tools = { "codelldb", "rustfmt" },
	},
	shell = {
		servers = { "bashls" },
		tools = { "shellcheck", "shfmt" },
	},
	sql = {
		servers = {},
		tools = { "sqlfmt" },
	},
	yaml = {
		servers = { "yamlls" },
		tools = { "yamlfmt" },
	},
	json = {
		servers = { "jsonls" },
		tools = { "jq" },
	},
	markdown = {
		servers = {},
		tools = { "mdformat", "markdownlint" },
	},
}

local function flatten(list)
	local out, seen = {}, {}
	for _, v in ipairs(list) do
		if not seen[v] then
			seen[v] = true
			table.insert(out, v)
		end
	end
	return out
end

function M.servers()
	local acc = {}
	for _, g in pairs(M.groups) do
		if g.servers then
			for _, s in ipairs(g.servers) do
				table.insert(acc, s)
			end
		end
	end
	return flatten(acc)
end

function M.tools()
	local acc = {}
	for _, g in pairs(M.groups) do
		if g.tools then
			for _, t in ipairs(g.tools) do
				table.insert(acc, t)
			end
		end
	end
	return flatten(acc)
end

return M
