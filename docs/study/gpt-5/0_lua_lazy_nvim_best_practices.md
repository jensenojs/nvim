# lazy.nvim 最佳实践与配置要点

- 目标与范围
    - 为什么要用 lazy.nvim: 统一管理“副作用的发生时机”, 显式声明依赖, 提升可维护性与启动性能
    - 关注点: 插件规范(spec)的结构化、懒加载触发、opts vs config 语义、依赖与条件加载、性能与缓存、在线/离线策略
    - 参考链接:
        - GitHub: <https://github.com/folke/lazy.nvim>
        - Docs: <https://github.com/folke/lazy.nvim/blob/main/doc/lazy.nvim.txt>
        - Discussion(触发器): <https://github.com/folke/lazy.nvim/discussions/1713>
        - Discussion(opts vs config): <https://github.com/folke/lazy.nvim/discussions/1185>

- 大纲
    - 设计哲学: 将“状态变更”延迟到“可观测事件”
    - 插件规范结构: 单一职责与依赖拓扑
    - 懒加载触发与 defaults.lazy 策略
    - opts vs config、init 的执行时机与合并语义
    - cond 条件加载与在线/离线隔离
    - 性能与缓存: compile/cache/concurrency
    - 组织方式建议: 目录分层与可组合的最小 spec
    - 示例清单: LSP/补全/文件/界面/工具的典型触发
    - ASCII 调用路径
    - 流程图: 配置加载与懒加载触发

---

## 设计哲学

- 插件是“能力提供者”, 真正的副作用(键位、autocmd、UI)应在“合适的时机”发生。
- lazy.nvim 最核心的价值是把“加载/执行时机”从文件系统路径变成“事件/命令/按键/文件类型/条件”的显式声明。

## 插件规范结构

- 每个插件一个 spec 文件即可, 职责清晰：

```lua
return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  opts = { use_diagnostic_signs = true },
}
```

- 对于强依赖, 使用 `dependencies = { ... }`, 而不是在 `config()` 顶层 `require`。
- 避免在顶层做重副作用；把逻辑放进 `opts/config` 回调中。

## 懒加载触发与 defaults.lazy

- 触发器: `event`/`ft`/`cmd`/`keys`/`cond`。
- 任何一个触发器都会隐式地让插件变为懒加载。
- 建议默认策略:
    - `defaults.lazy = true`, 强制你为每个插件写清楚触发条件
    - 常用触发:
        - Completion: `InsertEnter`
        - LSP: `BufReadPre`, `BufNewFile`
        - Treesitter: `BufReadPost`
        - Telescope: `cmd = { "Telescope" }` + 常用 `keys`
        - GitSigns: `BufReadPre`
        - UI 组件: `VeryLazy` 或具体 `keys`

## opts vs config 与 init

- 要点摘录(结合官方讨论 #1185):
    - `opts` 用于“数据合并”, 由 lazy 注入到插件的 `setup()`；父/子 spec 的 `opts` 会合并。
    - `config` 在插件加载时执行, 适合“需要立即副作用”的收尾动作。
    - `init` 在插件加载前执行(启动阶段), 适合设置 `vim.g.*` 或运行时路径, 但避免重副作用。
- 实践建议:
    - 优先使用 `opts` + 插件自带 `setup(opts)` 模式；`config` 用于额外 glue 逻辑。

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  opts = { highlight = { enable = true } },
}
```

## cond 条件加载与在线/离线

- 通过 `cond = function() return require("core.env").is_online() end` 控制联网插件(Copilot、AI 等)。
- 通过 `cond = require("core.env").has_cmd("rg")` 控制依赖外部可执行文件的插件(Telescope live_grep 等)。

```lua
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  cond = function()
    return require("core.env").has_cmd("rg")
  end,
}
```

## 性能与缓存

- 重要项:
    - `performance.cache.enabled = true`: 启用模块缓存
    - `concurrency`: 并发安装/加载数量(结合你机器调高)
    - `install.missing = true`: 启动时补齐缺失插件
- 不建议“全局缓存所有模块”, 以免调试困难；保留默认的禁用事件列表。

## 组织方式建议

- 目录分层(建议):
    - `lua/plugins/completion/` 补全层(blink.cmp 或 nvim-cmp)
    - `lua/plugins/lsp/` LSP 管线(或放 `lua/lsp/` 更语义化)
    - `lua/plugins/treesitter/`, `ui/`, `git/`, `files/`, `diagnostics/`, `format/`, `cursor/`, `tools/`, `extras/`
- 每个 spec 只管一个插件, 少量 glue 逻辑；跨插件的“能力抽象”放到 `lua/**/core.lua`。

## 典型触发清单

- 补全(blink.cmp): `event = "InsertEnter"`
- LSP: `event = { "BufReadPre", "BufNewFile" }`
- Telescope: `cmd = { "Telescope" }`, 常用 `keys`
- Treesitter: `event = "BufReadPost"`, `build = ":TSUpdate"`
- GitSigns: `event = "BufReadPre"`
- Trouble: `cmd = { "Trouble", "TroubleToggle" }`
- UI 主题: `lazy = false` 或 `priority` 提升加载顺序

## ASCII 调用路径

```text
init.lua
  └─ lua/core/lazy.lua
       └─ require("lazy").setup(spec)
            ├─ plugins/... (懒加载: event/ft/cmd/keys/cond)
            └─ lsp/... (on_attach & capabilities)
```

## 流程图: 配置加载与懒加载触发

```mermaid
flowchart TD
  A[Neovim start] --> B[init.lua]
  B --> C[core/lazy.lua]
  C --> D[lazy.setup(spec)]
  D --> E{defaults.lazy?}
  E -->|true| F[等待触发]
  E -->|false| G[直接加载]
  F --> H[event/ft/cmd/keys/cond]
  H --> I[加载插件]
  I --> J[opts 合并 -> setup]
  J --> K[config 收尾]
```

## 补全层与 blink.cmp 的集成建议

- 将“补全提供者”抽象为 provider 接口, 默认选 blink.cmp；需要切换到 nvim-cmp 时, 仅在 `feature_flags.lua` 中切换。
- blink.cmp 提示:
    - 触发: `InsertEnter`
    - sources: LSP、path、buffer 等
    - 搭配 `LuaSnip` 提供 snippet 展开

```lua
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = { "L3MON4D3/LuaSnip" },
  opts = {
    sources = { "lsp", "path", "buffer" },
  },
}
```

## LSP 管线与 mason-lspconfig

- mason 负责“安装”, lspconfig 负责“连接”, mason-lspconfig 负责桥接。
- 将 `on_attach`/`capabilities`/`flags` 抽到 `lua/lsp/core.lua`；每个 server 一个 `servers/<name>.lua` 提供差异化 `settings`。

---

# 小结

- 把“时机”当作第一公民, 所有副作用都需要可观测触发。
- 通过 `opts` 主导配置合并, `config` 做少量 glue。
- 利用 `cond` 实现在线/离线与依赖探测；目录分层保持单一职责。
- 默认 blink.cmp, 保留可切换空间, 后续在隔离配置中落地实现。
