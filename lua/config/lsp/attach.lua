-- lua/lsp/attach.lua
-- 作用: 为 LspAttach 安装缓冲区级能力(按键/高亮/可选折叠)
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local LSP_ATTACH = vim.api.nvim_create_augroup("lsp.attach", {
	clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = LSP_ATTACH,

	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end
		local bufnr = event.buf

		-- 将“只需一次”的初始化与“按客户端能力”的初始化拆分
		local first_time_init = not vim.b[bufnr].__lsp_attach_inited
		if first_time_init then
			vim.b[bufnr].__lsp_attach_inited = true
		end

		-- 统一能力检测: 返回当前 LSP 客户端是否支持某个请求方法
		-- 说明: 为按键映射提供静默能力检查, 不支持时不执行、不提示
		local if_support = function(method)
			return require("utils.lsp").if_support(method, bufnr)
		end

		local lsp_keymaps = {

			-- goto somewhere
			["n|gi"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_implementation) then
						vim.lsp.buf.implementation()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (跳转到)实现"),
			["n|gd"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_definition) then
						vim.lsp.buf.definition()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (跳转到)定义"),
			["n|gt"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_typeDefinition) then
						vim.lsp.buf.type_definition()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (跳转到)类型定义"),
			["n|gr"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_references) then
						vim.lsp.buf.references()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)引用"),

			["n|<leader>o"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
						vim.lsp.buf.document_symbol()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)当前文件符号"),

			["n|<leader>O"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.workspace_symbol) then
						vim.lsp.buf.workspace_symbol()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)工作区符号"),

			-- vscode 行为兼容
			["n|<c-t>"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.workspace_symbol) then
						local symbol = vim.fn.expand("<cword>")
						vim.lsp.buf.workspace_symbol(symbol)
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: 在工作区查找当前光标下的符号"),

			-- help
			["n|K"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_hover) then
						vim.lsp.buf.hover()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (悬停时)显示文档、类型、定义位置等静态信息"),
			["in|<C-k>"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_signatureHelp) then
						vim.lsp.buf.signature_help()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: Signature Help"),

			--
			["n|<leader>lwa"] = map_callback(vim.lsp.buf.add_workspace_folder)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (添加)工作区文件夹"),
			["n|<leader>lwd"] = map_callback(vim.lsp.buf.remove_workspace_folder)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (删除)工作区文件夹"),
			["n|<leader>lwl"] = map_callback(vim.lsp.buf.list_workspace_folders)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (列出)工作区文件夹"),

			["n|<leader><f2>"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_rename) then
						vim.lsp.buf.rename()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (重命名)Symbol"),

			["n|<leader>lca"] = map_callback(function()
					if if_support(vim.lsp.protocol.Methods.textDocument_codeAction) then
						vim.lsp.buf.code_action()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: Code Action"),

			["n|<leader>lci"] = map_callback(function()
					if client.server_capabilities and client.server_capabilities.callHierarchyProvider then
						vim.lsp.buf.incoming_calls()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)被谁调用"),

			["n|<leader>lco"] = map_callback(function()
					if client.server_capabilities and client.server_capabilities.callHierarchyProvider then
						vim.lsp.buf.outgoing_calls()
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)我调用谁"),

			["n|<leader>ltc"] = map_callback(function()
					-- 依赖服务器扩展(Type Hierarchy), 若不可用则静默
					if vim.lsp.buf.typehierarchy then
						vim.lsp.buf.typehierarchy({
							kind = "subtypes",
						})
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)子类型"),

			["n|<leader>ltp"] = map_callback(function()
					if vim.lsp.buf.typehierarchy then
						vim.lsp.buf.typehierarchy({
							kind = "supertypes",
						})
					end
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (查找)父类型"),

			-- diagnostic
			-- 说明:
			--   1) open_float 会弹出当前光标处诊断信息的浮窗; 可根据需要传入 {border='rounded', focusable=false}
			--   2) setloclist 适合“当前文件”的诊断列表 (每个窗口有独立 loclist)
			--   3) setqflist 适合“工作区/跨文件”的诊断列表 (全局 quickfix)

			["n|<leader>lf"] = map_callback(function()
					vim.diagnostic.open_float()
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (打开)诊断信息"),

			["n|<leader>dl"] = map_callback(function()
					vim.diagnostic.setloclist({
						bufnr = 0,
						open = true,
					})
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (打开)当前文件的诊断列表"),

			["n|<leader>dL"] = map_callback(function()
					vim.diagnostic.setqflist({
						open = true,
					})
				end)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (打开)工作区诊断列表"),

			-- ["n|ldp"] = map_callback(vim.diagnostic.goto_prev):with_buffer(bufnr):with_noremap():with_silent()
			--     :with_desc("LSP: (跳转到)上一个诊断"),
			-- ["n|ldn"] = map_callback(vim.diagnostic.goto_next):with_buffer(bufnr):with_noremap():with_silent()
			--     :with_desc("LSP: (跳转到)下一个诊断"),

			["n|[d"] = map_callback(vim.diagnostic.goto_prev)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (跳转到)上一个诊断(快捷)"),
			["n|]d"] = map_callback(vim.diagnostic.goto_next)
				:with_buffer(bufnr)
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (跳转到)下一个诊断(快捷)"),

			-- omnifunc :
			-- 原生是 :<c-n>/<c-p> 选择, <c-y> 确认
			-- 追加一种选择方式 : <tab>/<s-tab>选择, <cr> 确认
			["i|<tab>"] = map_callback(function()
					return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
				end)
				:with_buffer(bufnr)
				:with_expr()
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (自动补全)选择下一个"),
			["i|<s-tab>"] = map_callback(function()
					return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
				end)
				:with_buffer(bufnr)
				:with_expr()
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (自动补全)选择上一个"),

			["i|<cr>"] = map_callback(function()
					return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
					-- return (vim.fn.complete_info({ 'mode' }).mode ~= '') and '<C-y>' or '<CR>'
				end)
				:with_buffer(bufnr)
				:with_expr()
				:with_noremap()
				:with_silent()
				:with_desc("LSP: (自动补全)选择确认 / 正常回车"),
		}

		if first_time_init then
			bind.nvim_load_mapping(lsp_keymaps)
		end

		-- 自动补全：打开 + 改键
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, bufnr, {
				autotrigger = true,
			})
		end

		-- 光标处文档高亮(当任一支持的客户端附加时设置一次)
		if
			if_support(vim.lsp.protocol.Methods.textDocument_documentHighlight)
			and vim.bo[bufnr].filetype ~= "bigfile"
			and not vim.b[bufnr].__lsp_doc_highlight_set
		then
			local hl_group = vim.api.nvim_create_augroup("lsp.highlight." .. bufnr, {
				clear = true,
			})
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = bufnr,
				group = hl_group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = bufnr,
				group = hl_group,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp.detach." .. bufnr, {
					clear = true,
				}),
				callback = function(ev)
					if ev.buf == bufnr then
						vim.lsp.buf.clear_references()
						-- 仅当没有任何剩余客户端支持 documentHighlight 时, 才移除高亮组
						local still_has = require("utils.lsp").if_support(vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr)
						if not still_has then
							pcall(vim.api.nvim_del_augroup_by_name, "lsp.highlight." .. bufnr)
						end
					end
				end,
			})
			vim.b[bufnr].__lsp_doc_highlight_set = true
		end

		-- 内联提示(当任一支持的客户端附加时开启一次)
		if if_support(vim.lsp.protocol.Methods.textDocument_inlayHint) and not vim.b[bufnr].__lsp_inlay_hint_enabled then
			-- Default enable inlay hints for this buffer
			pcall(vim.lsp.inlay_hint.enable, true, {
				bufnr = bufnr,
			})
			vim.b[bufnr].__lsp_inlay_hint_enabled = true
		end

		-- lsp支持折叠(仅需一次)
		if first_time_init then
			local function enable_folding_for_win(win)
				vim.wo[win].foldmethod = "expr"
				vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
			end
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == bufnr then
					enable_folding_for_win(win)
				end
			end
			-- Ensure future windows entering this buffer also get folding enabled
			local fold_group = vim.api.nvim_create_augroup("lsp.fold." .. bufnr, {
				clear = true,
			})
			vim.api.nvim_create_autocmd("BufWinEnter", {
				buffer = bufnr,
				group = fold_group,
				callback = function()
					local win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_buf(win) == bufnr then
						enable_folding_for_win(win)
					end
				end,
			})
		end
	end,
})
