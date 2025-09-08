# blink.cmp × tabout 集成说明(方案 A)

本文档解释在 `lua/plugins/completion/blink.lua` 中如何与 `tabout.nvim` 联动, 并给出排错建议。

## 目标与整体思路

- 使用 blink.cmp 作为唯一补全引擎(不引入 nvim-cmp)。
- 通过 blink 的 keymap 链式调用 `<Tab>/<S-Tab>`：
    1) snippet 占位跳转
    2) 补全列表(PUM)导航
    3) 调用 tabout 的 `<Plug>` 动作
- 不使用 blink 的 `'fallback'`, 避免与 tabout 的缩进兜底重复触发。

## 关键配置位置

文件：`lua/plugins/completion/blink.lua`

```lua
opts = {
  keymap = {
    preset = "enter",
    -- 方案 A(与 tabout 集成)
    ["<Tab>"] = {
      'snippet_forward',
      'select_next',
      function()
        local keys = vim.api.nvim_replace_termcodes('<Plug>(Tabout)', true, true, true)
        vim.api.nvim_feedkeys(keys, 'm', false)
      end,
    },
    ["<S-Tab>"] = {
      'snippet_backward',
      'select_prev',
      function()
        local keys = vim.api.nvim_replace_termcodes('<Plug>(TaboutBack)', true, true, true)
        vim.api.nvim_feedkeys(keys, 'm', false)
      end,
    },
  },
}
```

配套要求(见 `lua/plugins/cursor/tabout.lua`)：

- `tabkey = ''`、`backwards_tabkey = ''`(不直接占用 `<Tab>/<S-Tab>`)
- `completion = true`
- `act_as_tab = true`

## 行为矩阵

- PUM 可见：
    - 有 snippet 占位 → `snippet_forward/backward`
    - 否则 → `select_next/prev`
- PUM 不可见：
    - 有 snippet 占位 → `snippet_forward/backward`
    - 否则 → 调用 `<Plug>(Tabout)/(TaboutBack)`；若无法跳出, 由 tabout 的 `act_as_tab=true` 作为缩进兜底

为何不再加 `'fallback'`？

- 若在调用 `<Plug>(Tabout)` 后继续 `'fallback'`, 会在“跳出括号”后再次插入一个真实 `<Tab>`, 造成“双动作”(跳出 + 缩进)。

## 与 Snippets 的关系

- blink 的内置 `snippets` 源会自动加载：
    - `friendly-snippets`
    - `~/.config/nvim/snippets/`
- 可与自定义 snippets 并存；避免触发词重名即可。
- 若未来启用 LuaSnip 源, 建议禁用内置 `snippets` 源以防重复。

## 排错清单

- 查看是否有其他插入态 `<Tab>` 映射抢占：
    - `:verbose imap <Tab>`、`:verbose imap <S-Tab>`
- 确认 buffer-local 残留映射已清理(`blink.lua` 的 `init()` 已在 `LspAttach` 清除 `<Tab>/<S-Tab>/<CR>`)。
- 确认 tabout 生效且提供 `<Plug>`：
    - `:nmap <Plug>(Tabout)` 与 `:nmap <Plug>(TaboutBack)` 应可见。
- 若出现“双动作”, 检查是否误加了 `'fallback'` 或在 tabout 侧又绑定了 `<Tab>`。

## 参考

- blink.cmp: <https://cmp.saghen.dev/>
- tabout.nvim: <https://github.com/abecodes/tabout.nvim>
