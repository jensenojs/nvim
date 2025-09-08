# completion

<https://github.com/Saghen/blink.cmp/blob/main/doc/recipes.md>

意图: 补全引擎与片段生态。

当前实现:

- 使用 blink.cmp 作为补全引擎, 不接入 nvim-cmp
- 规格文件: `tmp/lua/plugins/completion/blink.lua`
- 懒加载: `InsertEnter`
- 片段: 使用 `rafamadriz/friendly-snippets` (可选)
- LSP 能力: 在 `tmp/lua/plugins/lsp/mason.lua` 中若检测到 blink.cmp, 则优先采用 `require('blink.cmp').get_lsp_capabilities()`; 否则遵循 Neovim 0.11+ 默认能力

迁移提示:

- 旧配置中的 `cmp.lua`/`cmp-nvim-lsp.lua`/`luasnip.lua` 已不再使用
- 如需扩展 sources, 可通过 `opts_extend = { 'sources.default' }` 进行叠加

---

## 设计与加载策略

- 核心目标: 替代 nvim-cmp, 提供更高性能、开箱即用的补全体验。
- 状态放置: 将补全能力集中在 `blink.cmp` 插件内部, 以统一来源与 UI 行为。
- 加载权衡:
    - InsertEnter: 启动极轻, 首次进入插入模式才加载补全。
    - VeryLazy: 更早可用并便于 LSP 能力合并, 但略增启动时加载量。

模块关系:

```
tmp/lua/core/lazy.lua
  └─ require("plugins/completion/blink")
tmp/lua/plugins/lsp/mason.lua
  └─ pcall(require, "blink.cmp").get_lsp_capabilities()  # 若可用则合并能力
```

## 常用配置

- 键位预设:

```lua
-- 在 `tmp/lua/plugins/completion/blink.lua` 中修改
opts = {
  keymap = { preset = "default" }, -- 可选: "super-tab" | "enter" | "none"
}
```

- 文档弹窗策略:

```lua
opts = {
  completion = {
    documentation = { auto_show = true } -- 或 false, 视个人偏好
  }
}
```

- 补全来源管理:

```lua
opts = {
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
},
opts_extend = { "sources.default" } -- 在其他模块追加来源时使用
```

- 模糊匹配器:

```lua
opts = {
  fuzzy = {
    implementation = "prefer_rust_with_warning" -- 可选: "lua" | "prefer_rust"
  }
}
```

## 最佳实践

- 能力合并时序:
    - 若希望 LSP 启动即携带 blink 能力, 可将 blink 的 `event` 由 `InsertEnter` 调整为 `VeryLazy`。
    - 当前实现采用“可用则合并”的策略, 未合并时使用 Neovim 0.11+ 默认能力, 稳健且简洁。

- 文档与消息 UI:
    - 若使用 `noice.nvim`, 建议将 `auto_show` 按需开启, 避免频繁弹窗干扰。
    - 需要时再按键触发文档弹窗, 保持编辑节奏连贯。

- 片段生态:
    - `friendly-snippets` 为可选依赖, 提供通用片段集。
    - 如需自定义语言片段, 直接追加 VSCode 风格片段或维护个人片段集。

- 避免重复功能:
    - 不要同时启用 `nvim-cmp` 与 `blink.cmp` 以免出现菜单竞争与能力叠加的不可控行为。

## 调试与健康检查

- 插件健康: 当前在 headless 模式下执行 `:checkhealth which-key` 未见输出, which-key 可能未提供专用 health 检查项, 属正常现象。
- 建议在交互模式下执行 `:checkhealth` 以查看全局环境与 UI 相关告警。
- 若补全菜单未出现:
    - 确认已进入插入模式; 或将 blink 加载事件改为 `VeryLazy` 以提前加载。
    - 执行 `:Lazy health` 查看依赖状态, 包括 Rust 匹配器可用性。
