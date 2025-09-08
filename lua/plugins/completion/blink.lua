-- https://github.com/Saghen/blink.cmp
-- 说明:
--   - 事件懒加载: InsertEnter
--   - 依赖: rafamadriz/friendly-snippets 提供通用片段库
local offline = require("config.environment").offline

return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
		"folke/lazydev.nvim",
		"xzbdmw/colorful-menu.nvim",
	},

	init = function()
		-- 后置接管 LspAttach：
		-- 1) 关闭原生 vim.lsp.completion, 以免与 blink 冲突
		-- 2) 删除 attach.lua 设置的 buffer 局部插入态键位 (<Tab>/<S-Tab>/<CR>), 让 blink 的全局/插件侧映射生效
		local api = vim.api
		local group = api.nvim_create_augroup("blink.cmp_takeover", {
			clear = true,
		})

		api.nvim_create_autocmd("LspAttach", {
			group = group,
			callback = function(ev)
				local bufnr = ev.buf
				local client = vim.lsp.get_client_by_id(ev.data and ev.data.client_id or 0)
				if client then
					pcall(vim.lsp.completion.enable, false, client.id, bufnr)
				end
				pcall(vim.keymap.del, "i", "<Tab>", {
					buffer = bufnr,
				})
				pcall(vim.keymap.del, "i", "<S-Tab>", {
					buffer = bufnr,
				})
				pcall(vim.keymap.del, "i", "<CR>", {
					buffer = bufnr,
				})
			end,
		})

		-- 立即对已存在的附加 buffer 执行一次接管, 避免错过早期的 LspAttach 事件
		local function takeover_buf(bufnr)
			if not vim.api.nvim_buf_is_loaded(bufnr) then
				return
			end
			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
			})
			if not clients or #clients == 0 then
				return
			end
			for _, client in ipairs(clients) do
				pcall(vim.lsp.completion.enable, false, client.id, bufnr)
			end
			pcall(vim.keymap.del, "i", "<Tab>", {
				buffer = bufnr,
			})
			pcall(vim.keymap.del, "i", "<S-Tab>", {
				buffer = bufnr,
			})
			pcall(vim.keymap.del, "i", "<CR>", {
				buffer = bufnr,
			})
		end
		for _, b in ipairs(api.nvim_list_bufs()) do
			takeover_buf(b)
		end
	end,

	opts = function()
		local sources = {
			-- 默认启用的补全来源
			default = { "lsp", "path", "snippets", "buffer", "lazydev" },
			providers = {
				path = {
					opts = {
						get_cwd = function(_)
							return vim.fn.getcwd()
						end,
					},
				},

				lazydev = {
					module = "lazydev.integrations.blink",
				},
			},
		}
		if not offline then
			table.insert(sources.default, "minuet")
			sources.providers.minuet = {
				name = "minuet",
				module = "minuet.blink",
				async = true,
				-- Should match minuet.config.request_timeout * 1000,
				-- since minuet.config.request_timeout is in seconds
				timeout_ms = 3000,
				score_offset = 50, -- Gives minuet higher priority among suggestions
			}
		end

		return {
			-- Shows a signature help window while you type arguments for a function
			signature = {
				enabled = true,
			},

			keymap = {
				-- Keymap preset: "enter"(回车确认)；Tab 链自定义, 整体手感近似 VSCode 的 super-tab
				preset = "enter",
                -- stylua: ignore start
                -- 说明：
                -- - 由 blink.cmp 统一接管 Insert 模式下的 <Tab> 行为；`minuet.lua` 不再绑定插入态 <Tab>(仅保留 Normal 模式的接受映射)。
                -- - 与 minuet 集成：Minuet 虚拟文本“始终优先”, 先于 snippet/补全/Tabout, 不依赖 PUM 是否可见。
                -- - 与 tabout 集成的方案(A)：
                --   1) PUM 可见时：若处于 snippet 跳位环境则优先 snippet_forward/snippet_backward；否则 select_next/select_prev。
                --   2) PUM 不可见时：若处于 snippet 跳位环境则 snippet 跳位；否则 <Plug>(Tabout)/(TaboutBack) 跳出配对符号。
                --   3) 若无法跳出：tabout 的 act_as_tab=true 会自行执行“缩进”作为最终兜底。
                -- - 不再追加额外 fallback：避免在执行 Tabout 后又插入真实 <Tab> 造成“双动作”。
                ["<Tab>"] = { -- 0) 若 Minuet 有虚拟文本建议, 优先接受并终止链
                function(_)
                    if not offline then
                        local ok_vt, vt = pcall(require, 'minuet.virtualtext')
                        if ok_vt and vt and vt.action.is_visible() then
                            vt.action.accept()
                            return true
                        end
                    end
                    -- return false
                end, -- 1) 处于 snippet 时先跳到下一个占位
                'snippet_forward', -- 2) PUM 可见时选择下一项
                'select_next', -- 3) 否则尝试 Tabout(失败则由 tabout 自行 act_as_tab 缩进)
                function()
                    local keys = vim.api.nvim_replace_termcodes('<Plug>(Tabout)', true, true, true)
                    vim.api.nvim_feedkeys(keys, 'm', false)
                end},
                ["<S-Tab>"] = { -- 与 <Tab> 对称的反向链
                -- 1) 处于 snippet 时回跳到上一个占位
                'snippet_backward', -- 2) PUM 可见时选择上一项
                'select_prev', -- 3) 否则尝试反向 Tabout
                function()
                    local keys = vim.api.nvim_replace_termcodes('<Plug>(TaboutBack)', true, true, true)
                    vim.api.nvim_feedkeys(keys, 'm', false)
                end},
				-- stylua: ignore end

				["<A-y>"] = {
					function()
						if not offline then
							require("minuet").make_blink_map()
						end
					end,
				},
			},

			appearance = {
				nerd_font_variant = "normal",
			},

			completion = {
				trigger = {
					prefetch_on_insert = false,
				},
				menu = {
					border = "rounded",
					draw = {
						-- We don't need label_description now because label and label_description are already
						-- combined together in label by colorful-menu.nvim.
						columns = {
							{ "kind_icon" },
							{
								"label",
								gap = 1,
							},
							{ "source_name" },
						},

						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
							source_name = {
								text = function(ctx)
									return string.format("[%s]", ctx.source_name)
								end,
								highlight = "Comment",
							},

							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									-- 1) Minuet 专用：按 provider 映射图标
									if ctx.source_name == "minuet" then
										local name = tostring(ctx.kind_name or "")
										local llm_icons = require("utils.icons").get("llm")
										local function pick_icon(n)
											if not n or n == "" then
												return nil
											end
											-- 原样匹配
											if llm_icons[n] then
												return llm_icons[n]
											end
											-- 归一化后匹配(去标点/转小写)
											local k = n:lower():gsub("%p", ""):gsub("%s", "")
											-- 构造一次性的小写映射
											local lc = {
												claude = llm_icons.claude,
												openai = llm_icons.openai,
												codestral = llm_icons.codestral,
												gemini = llm_icons.gemini,
												groq = llm_icons.Groq,
												openrouter = llm_icons.Openrouter,
												ollama = llm_icons.Ollama,
												llamacpp = llm_icons["Llama.cpp"],
												deepseek = llm_icons.Deepseek,
											}
											return lc[k]
										end

										local icon = pick_icon(name) or "󰚩" -- 通用 AI/robot 图标
										return icon .. (ctx.icon_gap or " ")
									end

									-- 2) Path 源：尽量用 devicons(若可用)
									if ctx.source_name == "Path" or ctx.source_name == "path" then
										local ok, devicons = pcall(require, "nvim-web-devicons")
										if ok then
											local dev_icon = devicons.get_icon(ctx.label)
											if dev_icon then
												return dev_icon .. (ctx.icon_gap or " ")
											end
										end
									end

									-- 3) 其他来源：lspkind 符号
									local ok_lk, lspkind = pcall(require, "lspkind")
									if ok_lk then
										return lspkind.symbolic(ctx.kind, {
											mode = "symbol",
										}) .. (ctx.icon_gap or " ")
									end
									-- 4) 兜底
									return (ctx.kind_icon or "") .. (ctx.icon_gap or " ")
								end,
								highlight = function(ctx)
									-- 让 minuet 的图标使用插件设置的高亮(BlinkCmpItemKindMinuet)
									if ctx.source_name == "minuet" and ctx.kind_hl then
										return ctx.kind_hl
									end
									-- Path 源若拿到 devicons 的 hl 就用；否则回退到默认 kind_hl
									if ctx.source_name == "Path" or ctx.source_name == "path" then
										local ok, devicons = pcall(require, "nvim-web-devicons")
										if ok then
											local _, dev_hl = devicons.get_icon(ctx.label)
											if dev_hl then
												return dev_hl
											end
										end
									end
									return ctx.kind_hl
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 300,
					window = {
						border = "rounded",
					},
				},
				list = {
					selection = {
						auto_insert = false,
					},
				},
			},

			sources = sources,

			-- 模糊匹配器: 优先使用 Rust, 找不到则静默回退到 Lua;
			fuzzy = {
				implementation = "prefer_rust",
				prebuilt_binaries = {
					download = true,
				},
			},
		}
	end,
	-- 允许通过 opts_extend 在其他地方扩展默认 sources
	opts_extend = { "sources.default" },
}
