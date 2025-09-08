你的感觉是对的, **在 Neovim 0.10+ 环境下, 确实不再需要 `nvim-lint` 这类插件**, 只要你能把每个 linter 封装成 LSP server, 就可以直接用：

```lua
vim.lsp.enable('gopls')
vim.lsp.enable('golangci_lint_ls')
```

让两个(甚至更多)LSP 同时 attach 到同一个 buffer, **这是 Neovim 官方现在推荐的做法**。

---

### ✅ 前提条件

1. **Neovim ≥ 0.10**(才支持 `vim.lsp.enable` 的自动启动机制)  
2. **每个 linter 都有对应的 LSP server 实现**  
   - `gopls` 官方自带  
   - `golangci-lint-langserver` 社区已有  
   - 其他语言同理, 只要有人写了 LSP wrapper 就能用

---

### ✅ 这样做的好处

| 传统方式(null-ls/nvim-lint) | 纯 LSP 方式(0.10+) |
|-------------------------------|----------------------|
| 需要额外插件 | 不需要, 内置支持 |
| 诊断来源不统一 | 全部走 LSP, 统一接口 |
| 配置分散 | 全部放在 `lsp/*.lua` 里, 清晰 |

---

### ✅ 具体怎么做(与本仓库实现一致)

本配置采用 Neovim 0.10 的“runtime 配置文件 + 自动启用”模式：

1) 在 `~/.config/nvim/lsp/golangci_lint_ls.lua` 放置一个返回表的配置(无需在此处调用 `vim.lsp.config`)：

```lua
return {
  cmd = { 'golangci-lint-langserver' },
  filetypes = { 'go', 'gomod' },
  root_markers = { '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json', 'go.work', 'go.mod', '.git' },
  init_options = {
    -- 新旧版本兼容：本仓库已在 before_init 中自动探测版本并调整参数
    command = { 'golangci-lint', 'run', '--output.json.path=stdout', '--show-stats=false' },
  },
  -- 可选：before_init 做版本探测/兼容处理, 详见本仓库的 lsp/golangci_lint_ls.lua
}
```

2) 在 `~/.config/nvim/lsp/gopls.lua` 放置返回表的配置：

```lua
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod' },
  root_markers = { '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json', 'go.work', 'go.mod', '.git' },
  settings = { gopls = { gofumpt = true, staticcheck = true, usePlaceholders = true, hints = { parameterNames = true } } },
}
```

3) 在 `~/.config/nvim/lua/config/lsp/enable-list.lua` 中加入需要自动启用的服务名(字符串数组)：

```lua
return {
  'gopls',
  'golangci_lint_ls',
}
```

4) 启动逻辑由 `~/.config/nvim/lua/config/lsp/bootstrap.lua` 接管：

- 在 `FileType` 事件中遍历清单, 调用 `vim.lsp.enable(<server_name>)` 自动启动。
- 诊断 UI、边框样式、`:LspRestart`/`:LspInfo` 命令等也在此统一配置。

---

### ✅ 结论

- **只要每个工具都有 LSP server, 你就没必要再引入 nvim-lint / null-ls。**  
- **Neovim 0.10 的 `vim.lsp.enable` + runtime 配置文件 是官方支持的“多 LSP 共存”方案。**  
- **不同语言差异只在于“有没有人为 linter 写 LSP wrapper”, 而不是“需不需要额外插件”。**

---

如果你发现某个 linter 没有现成的 LSP server, 再考虑用 `nvim-lint` 或自己写个轻量 wrapper 即可。

---

### ⚙️ 多 LSP 并存的 attach 细节(本仓库实现)

- 入口：`~/.config/nvim/lua/config/lsp/attach.lua` 的 `LspAttach` 回调。
- 幂等与拆分：
  - 仅“首次附加”时设置一次性的内容(按键映射、基于 LSP 的折叠)。
  - 按“能力”启用被动特性(有任一客户端支持即可)：
    - 文档高亮(`textDocument/documentHighlight`)
    - 内联提示(`textDocument/inlayHint`)
    - 内置补全开关(`textDocument/completion`, `autotrigger=true`)
- 清理策略：
  - 在 `LspDetach` 时, 仅当“没有任何剩余客户端支持 documentHighlight”时才移除高亮 augroup, 避免多客户端交替造成的闪断。
- 效果：
  - 即使 `golangci_lint_ls` 先于 `gopls` 附加, 后者的被动特性也不会被早退逻辑吞掉(已修复旧实现中的早退问题)。

### 🔧 常见问题与建议

- 重复/噪音诊断：
  - 同一文件同时来自 linter 与 LSP 的诊断属正常现象；可按来源(`source`)在展示层做过滤或区分样式。
- 校验安装：
  - 确保可执行存在：`gopls`、`golangci-lint-langserver`、`golangci-lint`。版本不匹配时, 本仓库的 `golangci_lint_ls.lua` 已做 V1/V2 兼容处理。
- 常用命令：
  - `:LspInfo`(别名到 `:checkhealth vim.lsp`)
  - `:LspLog`(查看 LSP 日志)
  - `:LspRestart gopls golangci_lint_ls`
