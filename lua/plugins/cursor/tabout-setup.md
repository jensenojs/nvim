# tabout.nvim 配置与使用

本文档专门说明 `lua/plugins/cursor/tabout.lua` 的设置方式, 以及与 `blink.cmp` 的协作要点。

## 目标

- 在不直接占用 `<Tab>/<S-Tab>` 的情况下, 提供“跳出成对符号”的能力。
- 由 `blink.cmp` 统一接管 `<Tab>/<S-Tab>` 的决策(snippet 跳位 / PUM 导航 / Tabout / 缩进兜底)。

## 关键配置

文件：`lua/plugins/cursor/tabout.lua`

```lua
require('tabout').setup {
  tabkey = '',                -- 不直接绑定 <Tab>
  backwards_tabkey = '',      -- 不直接绑定 <S-Tab>
  completion = true,          -- 与补全菜单联动
  act_as_tab = true,          -- 不能跳出时, 自己当作 Tab 缩进(兜底)
  act_as_shift_tab = false,
  default_tab = '<C-t>',
  default_shift_tab = '<C-d>',
  enable_backwards = true,
  -- 其它配对符见文件内 `tabouts` 列表
}
```

`tabkey=''` 与 `backwards_tabkey=''` 的原因：

- 让 `tabout.nvim` 仅提供 `<Plug>(Tabout)` 与 `<Plug>(TaboutBack)`, 不抢 `<Tab>/<S-Tab>`。
- 由 `blink.cmp` 在其 keymap 链中调用这两个 `<Plug>`, 避免冲突与“双动作”。

## 与 blink.cmp 的协作

在 `lua/plugins/completion/blink.lua`：

- `<Tab>`：`snippet_forward` → `select_next` → 调用 `<Plug>(Tabout)`(不再 `fallback`)
- `<S-Tab>`：`snippet_backward` → `select_prev` → 调用 `<Plug>(TaboutBack)`(不再 `fallback`)
- 若不能跳出, `tabout` 的 `act_as_tab=true` 会自动插入缩进, 形成最终兜底。

## 验证步骤

1. 打开含成对符号的行(如 `(|)` 代表光标位置)。
2. 插入模式按 `<Tab>`：应跳出到括号外, 不产生额外缩进。
3. 无成对符号时按 `<Tab>`：应表现为正常缩进(来自 `tabout` 的兜底)。
4. 有补全菜单时按 `<Tab>/<S-Tab>`：在列表中导航, 不触发跳出或缩进。

## 常见问题排查

- 观察是否有其他 `<Tab>` 映射：`:verbose imap <Tab>`、`:verbose imap <S-Tab>`。
- 确认 `blink.lua` 未在 `<Tab>`/`<S-Tab>` 链末尾加 `'fallback'`, 否则会出现“跳出 + 额外缩进”的双动作。
- 确认 `tabout` 提供 `<Plug>`：`:nmap <Plug>(Tabout)`、`:nmap <Plug>(TaboutBack)`。

## 参考

- tabout.nvim: <https://github.com/abecodes/tabout.nvim>
- blink.cmp: <https://cmp.saghen.dev/>
