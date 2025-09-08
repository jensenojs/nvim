# diagnostics

意图: 问题列表与诊断面板, 未来还需要包括调试, 以及静态代码检测

- /Users/jensen/.config/nvim/lua/plugins/ui/trouble.lua

- trouble: 诊断列表/符号浏览/LSP/quickfix 统一 UI。
    - 触发: `event = "VeryLazy"`, `cmd = "Trouble"`, 多个 `<leader>?*` 快捷键
    - 仓库: <https://github.com/folke/trouble.nvim>
    - 配置: `lua/plugins/ui/trouble.lua`

<https://github.com/folke/snacks.nvim/blob/main/docs/debug.md>

more : nvim-lint

## dap

意图: 调试协议栈与 UI。

原路径映射:

- /Users/jensen/.config/nvim/lua/plugins/ide/dap/dap.lua
- /Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-ui.lua
- /Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-virtual-text.lua
- /Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-repl-highlights.lua
