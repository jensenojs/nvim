# Neovim LSP 最小化配置(无插件前提)

本目录在不依赖第三方插件的前提下, 提供开箱即用的 LSP 基础能力；并在未来引入插件时, 做到“各司其职, 可无缝接管”。

建议 Neovim 版本：0.10+(使用 `vim.lsp.enable()`、内置 completion/fold)。

---

## 目录结构

- `enable_list.lua`
    - LSP 服务“白名单”清单(字符串数组)。
- `bootstrap.lua`
    - LSP 运行时初始化：诊断 UI、handler 边框、用户命令、自动启用服务等。
- `attach.lua`
    - 在 `LspAttach` 事件里为当前 buffer 注入能力(按键绑定、内置补全、文档高亮、折叠等)。

---

## 启动流程(无插件)

1) 读取服务清单

- `bootstrap.lua` 在 `FileType` 回调中读取 `enable_list.lua`, 对每个条目执行 `vim.lsp.enable(<server_name>)`。

2) 注册全局 UI/命令

- 诊断 UI：`vim.diagnostic.config()` 统一虚拟文本、下划线、sign、排序与浮窗样式(圆角边框、来源展示)。
- handler 边框：用 `vim.lsp.with()` 给 `hover`、`signatureHelp` 设置圆角边框。
- 用户命令：
    - `:LspInfo`(别名到 `:checkhealth vim.lsp`)
    - `:LspLog`(在新 tab 打开 LSP 日志)
    - `:LspRestart <server...>`(带白名单补全, 逐个停-启目标服务)

3) Buffer 级能力(`LspAttach` 中)

- 幂等保护：每个 buffer 仅注入一次(`vim.b[bufnr].__lsp_attach_inited`)。
- 跳转/查询：
    - `gi` 实现、`gd` 定义、`gt` 类型定义、`gr` 引用
    - `<leader>o` 当前文件符号、`<leader>O` 工作区符号(后续可交给 telescope)
- 文档/签名：
    - `K` 悬停(hover)
    - `Ctrl-k`(插入/正常)签名帮助(signature help)
- 工作区：
    - `<leader>lwa` / `lwd` / `lwl`：增/删/列出工作区文件夹
- 代码变更：
    - `<leader>lrn` 重命名
    - `<leader>lca` Code Action
- 层级关系(若服务器支持)：
    - `<leader>lci`/`lco`：调用层级(incoming/outgoing)
    - `<leader>ltc`/`ltp`：类型层级(子类型/父类型)
- 诊断(diagnostic)：
    - `<leader>ld` 打开光标处诊断浮窗
    - `<leader>lq` 当前文件诊断列表(loclist)
    - `<leader>lQ` 工作区诊断列表(quickfix)
    - `ldp`/`ldn` 与 `[d`/`]d` 诊断跳转
- 补全(内置, 无插件)：
    - 开启：`vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })`
    - 插入模式选择/确认(仅当补全菜单可见时生效, 使用 `utils.bind` 的 expr 映射, 带 fallback)：
        - `<Tab>` 选择下一个(否则回退为原 `<Tab>`)
        - `<S-Tab>` 选择上一个(否则回退为原 `<S-Tab>`)
        - `<CR>` 确认(否则回退为原 `<CR>`)
- 文档高亮(documentHighlight)：
    - `CursorHold`/`CursorHoldI` 自动高亮, `CursorMoved`/`CursorMovedI` 清除；`LspDetach` 时清理。
- 折叠(基于 LSP)：
    - 为与当前 buffer 关联的窗口设置：`foldmethod=expr`、`foldexpr=v:lua.vim.lsp.foldexpr()`
    - 通过 `BufWinEnter` 自动命令确保后续进入该 buffer 的窗口也启用折叠。

> 所有绑定在执行动作前均做了能力检查(例如仅当支持 `hover` 才执行 `vim.lsp.buf.hover()`), 不支持时静默。

---

## 如何增删 LSP 服务器

1) 编辑清单 `config/lsp/enable_list.lua`

```lua
return {
  "bashls",
  "clangd",
  "gopls",
  "lua_ls",
  "rust_analyzer",
}
```

2) 重启服务

```vim
:LspRestart lua_ls gopls
```

或重新打开相应文件, `bootstrap.lua` 会在 `FileType` 时自动启用。

---

## 与插件的分工边界(未来接管)

- 补全：
    - 当前使用内置 `vim.lsp.completion` + PUM 键位(`<Tab>/<S-Tab>/<CR>` expr + fallback)。
    - 引入 `blink.cmp`/`nvim-cmp` 后, 可移除这些键位映射并交由插件接管。
- 模糊查找/TUI：
    - 目前用内置命令与 loclist/quickfix。
    - 引入 `telescope.nvim` 后, 可将符号/引用/实现等入口迁移到 Telescope；诊断列表可交由 `trouble.nvim`。
- Inlay Hints：
    - `attach.lua` 中示例默认注释；可由插件或手动启用。
- 折叠/高亮：
    - 使用内置 `vim.lsp.foldexpr()` 与 `documentHighlight`；引入插件时保持兼容或让插件接管。

原则：保持“可退化”的默认实现——即使卸载插件, 仍保留 LSP 基础可用性。

---

## 自定义与扩展

- 键位体系：
    - 当前借助 `utils.bind`(`utils/bind.lua`)做描述式绑定(如 `:with_buffer():with_noremap():with_silent():with_desc():with_expr()`)。
    - 也可直接改用 `vim.keymap.set`, 或按需调整具体按键。
- 诊断 UI：
    - 在 `bootstrap.lua` 的 `diagnostic.config()` 中调整, 如关闭 `virtual_text`、修改浮窗边框等。
- 条件注入：
    - 在 `attach.lua` 的 `LspAttach` 回调里可根据 `client.name` 或 `vim.bo.filetype` 做差异化按键。

---

## 常见问题(FAQ)

- “补全菜单不弹？”
    - 确认服务器支持 `textDocument/completion`；本配置会在 `attach` 时开启内置 completion 且 `autotrigger = true`。
    - 若由插件接管补全, 注意与这里的 `<Tab>/<S-Tab>/<CR>` 不要冲突。
- “为什么会重复注入？”
    - `attach.lua` 已做幂等保护(`vim.b[bufnr].__lsp_attach_inited`)。
- “诊断列表用哪个？”
    - 当前文件建议用 loclist(`<leader>lq`), 跨文件建议用 quickfix(`<leader>lQ`)。

---

## 参考命令

```vim
:LspInfo      " 别名到 :checkhealth vim.lsp
:LspLog       " 打开 LSP 日志
:LspRestart   " 带白名单补全, 重启指定服务器
```
