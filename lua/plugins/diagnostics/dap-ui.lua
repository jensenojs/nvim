-- https://github.com/rcarriga/nvim-dap-ui
-- 调试界面的配置
-- 设计要点：
-- 1) 懒加载：本插件在 lazy.nvim 的 `VeryLazy` 事件时才加载, config() 也只在加载发生时执行；
--    避免启动期执行重逻辑；配置中的 require("dap")/require("dapui") 也仅在此时求值。
-- 2) 会话期键位：只在 DAP 会话开始时加载(临时覆盖 K 键), 会话结束时恢复原 K 键, 避免键位“污染”。
-- 3) 生命周期监听：使用 `dap.listeners.*["dapui_config"] = function() ... end` 命名空间, 
--    确保多次设置时是覆盖而非叠加, 不会产生重复回调。
local M = {}

-- 调试期间的键位映射管理
local debug_keymaps_loaded = false
-- 记录会话开始前 K 键的原有映射(分别记录普通/可视模式), 用于会话结束时恢复
local prev_keymaps = {
    n = nil,
    v = nil
}

-- 加载调试期间的键位映射
function M.load_debug_keymaps()
    if debug_keymaps_loaded then
        return
    end

    -- 捕获当前 K 键原映射, 便于会话结束时恢复(避免“污染”用户原有配置)
    local function capture_existing(mode)
        -- 优先使用新 API: vim.keymap.get (Neovim 0.10+)
        local keymap_get = vim.keymap and vim.keymap.get
        if type(keymap_get) == "function" then
            local list = keymap_get(mode, "K") or {}
            return list[1]
        end

        -- 兼容旧版: 回退到 nvim_buf_get_keymap / nvim_get_keymap
        local function find_in(maps)
            for _, map in ipairs(maps) do
                if map.lhs == "K" then
                    return map
                end
            end
        end
        -- 先查缓冲区映射, 再查全局映射
        local buf_map = find_in(vim.api.nvim_buf_get_keymap(0, mode))
        if buf_map then
            -- 标记为 buffer-local, 便于恢复时按 buffer 维度设置
            buf_map.buffer = 0
            return buf_map
        end
        return find_in(vim.api.nvim_get_keymap(mode))
    end
    prev_keymaps.n = capture_existing("n")
    prev_keymaps.v = capture_existing("v")

    local bind = require("utils.bind")
    local map_cmd = bind.map_cmd

    local debug_keymaps = {
        ["nv|K"] = map_cmd("<Cmd>lua require('dapui').eval()<CR>"):with_noremap():with_nowait():with_desc(
            "Debug: Evaluate expression under cursor")
    }

    bind.nvim_load_mapping(debug_keymaps)
    debug_keymaps_loaded = true
end

-- 清理调试期间的键位映射
function M.clear_debug_keymaps()
    if not debug_keymaps_loaded then
        return
    end

    -- 清理调试键位映射
    pcall(vim.keymap.del, "n", "K")
    pcall(vim.keymap.del, "v", "K")

    -- 恢复会话前的原映射(若存在)。
    local function restore(map, mode)
        if not map then
            return
        end
        local opts = {
            silent = map.silent,
            noremap = map.noremap,
            expr = map.expr,
            nowait = map.nowait,
            desc = map.desc,
            buffer = map.buffer
        }
        if map.callback then
            pcall(vim.keymap.set, mode, "K", map.callback, opts)
        elseif map.rhs then
            pcall(vim.keymap.set, mode, "K", map.rhs, opts)
        end
    end
    restore(prev_keymaps.n, "n")
    restore(prev_keymaps.v, "v")
    prev_keymaps.n, prev_keymaps.v = nil, nil

    debug_keymaps_loaded = false
end

return {
    "rcarriga/nvim-dap-ui",
    dependencies = {"nvim-neotest/nvim-nio"},
    main = "dapui",
    lazy = true,

    opts = function()
        local icons = {}
        local ok, icon_module = pcall(require, "utils.icons")
        if ok then
            icons = {
                ui = icon_module.get("ui"),
                dap = icon_module.get("dap")
            }
        end
        return {
            force_buffers = true,
            icons = {
                expanded = icons.ui and icons.ui.ArrowOpen or "v",
                collapsed = icons.ui and icons.ui.ArrowClosed or ">",
                current_frame = icons.ui and icons.ui.Indicator or "->"
            },
            mappings = {
                edit = "e",
                expand = {"<CR>", "<2-LeftMouse>"},
                open = "o",
                remove = "d",
                repl = "r",
                toggle = "t"
            },
            controls = {
                enabled = true,
                element = "repl",
                icons = {
                    pause = icons.dap and icons.dap.Pause or "⏸",
                    play = icons.dap and icons.dap.Play or "▶",
                    step_into = icons.dap and icons.dap.StepInto or "⏎",
                    step_over = icons.dap and icons.dap.StepOver or "⏭",
                    step_out = icons.dap and icons.dap.StepOut or "⏮",
                    step_back = icons.dap and icons.dap.StepBack or "b",
                    run_last = icons.dap and icons.dap.RunLast or "▶▶",
                    terminate = icons.dap and icons.dap.Terminate or "⏹"
                }
            },
            floating = {
                max_height = nil,
                max_width = nil,
                mappings = {
                    close = {"q", "<Esc>"}
                }
            },
            render = {
                indent = 1,
                max_value_lines = 85
            }
        }
    end,

    config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)

        -- 调试会话生命周期管理
        dap.listeners.after.event_initialized["dapui_config"] = function()
            M.load_debug_keymaps()
            local ok_focus, focus = pcall(require, "focus")
            if ok_focus then
                focus.setup({
                    enable = false
                })
            end
            dapui.open({
                reset = true
            })
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
            local ok_focus, focus = pcall(require, "focus")
            if ok_focus then
                focus.setup({
                    enable = true
                })
            end
            M.clear_debug_keymaps()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
            local ok_focus, focus = pcall(require, "focus")
            if ok_focus then
                focus.setup({
                    enable = true
                })
            end
            M.clear_debug_keymaps()
        end

        -- 配置断点图标
        local icons = {}
        local ok, icon_module = pcall(require, "utils.icons")
        if ok then
            icons = icon_module.get("dap") or {}
        end
        vim.fn.sign_define("DapBreakpoint", {
            text = icons.Breakpoint or "B",
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapBreakpointCondition", {
            text = icons.BreakpointCondition or "C",
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapStopped", {
            text = icons.Stopped or "->",
            texthl = "DapStopped",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapBreakpointRejected", {
			text = icons.BreakpointRejected,
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})
		vim.fn.sign_define("DapLogPoint", {
			text = icons.LogPoint,
			texthl = "DapLogPoint",
			linehl = "",
			numhl = "",
		})
    end
}
