概述与结论

- 目标: 用 conform.nvim 取代 `guard.nvim` 的格式化能力, 保留现有语言与链式格式化体验
- 结论: 可以等价替换, 且支持懒加载。你在 `guard.nvim` 中使用的格式化器均为 conform.nvim 内置:
    - jq, shfmt, black, isort, clang-format, gofmt, goimports, sqlfmt, stylua
    - LSP 格式化可通过 `lsp_format` 策略控制(fallback/prefer/first/last)
- 差异: conform.nvim 专注“格式化”, 不内置“lint”。`guard.nvim` 中的 `:lint("selene")` 需要另配 `nvim-lint` 或其他工具

- 选择建议:
    - 只做“格式化”、要强大的懒加载与生态: 用 conform.nvim
    - 同时要“格式化+lint”且偏好在同一 DSL 链式管理: 用 guard.nvim(或配合 `nvim-lint`/`none-ls.nvim` 与 conform 组合)

能力对齐与映射

- guard.nvim 当前配置参考: `lua/plugins/format/guard.lua:L35-L73`
- conform.nvim 的等价映射建议:
    - json → jq
    - sh → shfmt
    - python → isort, black (可根据可用性切换 ruff_format)
    - c → clang-format
    - go → goimports, gofmt
    - sql → sqlfmt
    - lua → stylua (+ 可设 `lsp_format = "fallback"` 以在无 formatter 时走 LSP)

快速上手配置

- 大纲:
    - lazy.nvim 懒加载推荐写法
    - formatters_by_ft 的等价映射示例
    - format_on_save 与按需触发
    - 自定义单个 formatter 参数

```lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true })
      end,
      mode = "n",
      desc = "Format buffer",
    },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      json = { "jq" },
      sh = { "shfmt" },
      python = function(bufnr)
        local c = require("conform")
        if c.get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
      c = { "clang-format" },
      go = { "goimports", "gofmt" },
      sql = { "sqlfmt" },
      lua = { "stylua" },
      ["_"] = { "trim_whitespace" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = { timeout_ms = 500 },
    formatters = {
      shfmt = { append_args = { "-i", "2" } },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
```

运行机制概览

- 大纲:
    - 选择器: 依据 `formatters_by_ft` 与可用性筛选格式化器
    - 链式执行: 默认顺序串行, 可 `stop_after_first` 只跑第一个可用
    - LSP 策略: never/fallback/prefer/first/last
    - 范围格式化与异步

```mermaid
flowchart TD
  K[Keymap <leader>f] --> F[conform.format]
  F --> R{Resolve formatters}
  R -->|available| S[Run sequentially]
  R -->|none| L[LSP format (if fallback)]
  S --> A[Apply edits]
  L --> A
```

常见配方摘录

- 大纲:
    - 开关 format-on-save
    - 懒加载模板
    - 自定义 formatter 参数

开启/关闭 format-on-save:

```lua
require("conform").setup({
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
end, { bang = true })
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {})
```

调试与排错

- 大纲:
    - `:ConformInfo` 查看日志位置、可用性与决策链
    - `require("conform").list_formatters()`/`get_formatter_info()`
    - `notify_on_error`, `notify_no_formatters`, `log_level`

示例:

```lua
:ConformInfo
```

- 无可用 formatter 时, 若设置了 `lsp_format = "fallback"`, 将回退至 LSP

文件与代码引用

- 你的懒加载按键映射: `lua/plugins/format/conform.lua:L6-L15`
- 你的 guard.nvim 等价需求: `lua/plugins/format/guard.lua:L35-L73`

注意事项与权衡

- 格式化 vs. Lint: conform 专注格式化, 需搭配 `nvim-lint`/`none-ls.nvim` 提供 lint
- 外部依赖: 需在系统中安装相应二进制(jq/shfmt/black/isort/clang-format/goimports/sqlfmt/stylua 等)
- 状态与性能: 串行运行多个 formatter 会增加时延; 可通过 `stop_after_first` 或 `format_after_save` 平衡交互体验

ruff_format 与安装

- ruff_format 来源: conform.nvim 内置的 `ruff_format` 格式化器, 实际调用 `ruff format`(需 ruff>=0.4)。
- 安装建议(mac):
    - Python 工具: `pipx install ruff black isort` 或 `pip3 install --user ruff black isort`
    - 其他: `brew install jq shfmt clang-format goimports sqlfmt stylua`
    - Go: `go install golang.org/x/tools/cmd/goimports@latest`
- 可用性检查: `:ConformInfo` 或 `require("conform").get_formatter_info("ruff_format", 0)`

如何配置 formatter 选项

- 覆盖/自定义单个 formatter:

```lua
-- 在插件 spec 的 opts.formatters 中
require("conform").formatters.shfmt = {
  append_args = { "-i", "2" },
}

-- rustfmt 额外选项(doc/formatter_options.md)
require("conform").formatters["rustfmt"] = {
  options = { default_edition = "2021" },
}
```

- 按文件类型设定格式化链:

```lua
require("conform").setup({
  formatters_by_ft = {
    python = function(bufnr)
      local c = require("conform")
      if c.get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
  },
})
```

扩展语言示例(rust/cpp)

```lua
-- 在你的 `lua/plugins/format/conform.lua` 的 opts.formatters_by_ft 中加入:
rust = { "rustfmt" },
cpp  = { "clang-format" },

-- 可选: 细化 rustfmt 行为
require("conform").formatters["rustfmt"] = {
  options = { default_edition = "2021" },
}
```

guard.nvim 概览与用法

- 能力: 同时支持格式化与 lint, 链式 `.fmt():append():lint()`; 可通过 `vim.g.guard_config` 启/停自动格式化与自动 lint, 以及 LSP 回退。
- 基本用法:

```lua
local ft = require("guard.filetype")
ft("python"):fmt("isort"):append("black"):lint("mypy")
require("guard").setup({
  fmt_on_save = true,
  lsp_as_default_formatter = false,
  auto_lint = true,
})
```

- 常用命令: `:Guard fmt`, `:Guard lint`, `:Guard enable-fmt`, `:Guard disable-fmt` 等。

conform.nvim 与 guard.nvim 对比(要点)

- 关注点:
    - conform: 专注“格式化”, 内置 formatter 多、懒加载与调试体验成熟(`:ConformInfo`)。
    - guard: “格式化+lint”一体化 DSL, 但 lint 能力需依赖外部工具; 懒加载需借助包管理器控制。
- LSP 策略:
    - conform: `lsp_format = never/fallback/prefer/first/last` 粒度更细。
    - guard: `lsp_as_default_formatter` 作为兜底策略。
- 懒加载与键位:
    - conform: 官方 recipes 提供成熟懒加载与按键样例。
    - guard: 可懒加载, 但按键触发需确保插件已加载(你之前用 `lazy.load` 手动确保)。
- 调试与可观测性:
    - conform: `:ConformInfo` 可查看可用性、决策链、日志位置。
    - guard: 以命令为主, 需自己观察外部工具输出。
- 迁移成本:
    - 你的现有映射可一键迁移至 conform(已在 `lua/plugins/format/conform.lua` 完成)。

选择建议(再次总结)

- 仅需格式化、追求稳定与生态: 选 conform.nvim。
- 偏好在一个 DSL 里同时管理格式化与 lint, 并接受自行安装/维护各类 linter: 选 guard.nvim 或 conform+`nvim-lint` 组合。
