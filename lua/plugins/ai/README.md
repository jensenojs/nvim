# ai

意图: AI 辅助, 使用 opencode.nvim, 和 minuet-ai.nvim

原路径映射:

- /Users/jensen/.config/nvim/lua/plugins/ai/minuet.lua

- <https://github.com/milanglacier/minuet-ai.nvim>

- https://github.com/NickvanDyke/opencode.nvim
- https://github.com/yetone/avante.nvim
- https://github.com/gitsang/qwen-code.nvim

## Minuet 集成说明(虚拟文本优先, 避免与 PUM 干扰)

本节基于 minuet-ai.nvim 官方文档整理, 目标：

- 仅启用“AI Ghost Text(虚拟文本)”, 不引入补全源, 确保 `<Tab>` 可在“仅当可见时”接受 AI 建议。
- 与 blink.cmp 解耦；后续如需再作为补全源加入, 采用“手动触发”方式以避免时序/评分干扰。

### 1) 安装(lazy.nvim)

```lua
-- 文件：lua/plugins/ai/minuet.lua(已提供)
return {
  'milanglacier/minuet-ai.nvim',
  event = 'InsertEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- 可选：如仅用虚拟文本, 不需要以下两项
    -- 'hrsh7th/nvim-cmp',
    -- 'saghen/blink.cmp',
  },
  opts = {
    virtualtext = {
      -- 关闭自动触发, 避免与 PUM 干扰；按需改为 { 'lua', 'typescript', ... }
      auto_trigger_ft = {},
      -- 可自定义按键(示例见下一小节)
      -- keymap = { accept = '<A-l>', accept_line = '<A-;>', accept_n_lines = '<A-\'>' }
    },
    -- provider 与 model 示例见下文“提供商与 API Key 配置”
  },
  config = function(_, opts)
    local ok, minuet = pcall(require, 'minuet')
    if not ok then
      vim.notify('[minuet] 未找到 minuet-ai.nvim, 请确认已正确安装', vim.log.levels.WARN)
      return
    end
    minuet.setup(opts)
  end,
}
```

> 说明：Minuet 无需本地守护进程, 纯 HTTP 请求, 避免了“server 为 nil”类初始化竞态。

### 2) 仅虚拟文本：按键映射与使用

Minuet 暴露虚拟文本操作 API, 可用于自定义按键：

```lua
-- API 入口
local vt = require('minuet.virtualtext')
-- 可用动作
-- vt.action.accept()        -- 接受整条
-- vt.action.accept_line()   -- 接受一行
-- vt.action.accept_n_lines()-- 接受 N 行(会提示输入数字)
-- vt.action.next()          -- 下一条/手动触发
-- vt.action.prev()          -- 上一条/手动触发
-- vt.action.dismiss()       -- 关闭当前虚拟文本
-- vt.action.is_visible()    -- 当前 buffer 是否可见

-- 示例：为 Alt 系列绑定
vim.keymap.set('i', '<A-y>', function() vt.action.next() end, { silent = true })
vim.keymap.set('i', '<A-e>', function() vt.action.dismiss() end, { silent = true })
vim.keymap.set('i', '<A-l>', function() vt.action.accept() end, { silent = true })
```

> 若你暂时禁用 blink(甚至注释掉 `blink.lua`), 也可用下述“最小可用”的 `<Tab>` 接受映射：

```lua
-- 仅当虚拟文本可见时, 用 <Tab> 接受；否则退回插入真实 Tab
vim.keymap.set('i', '<Tab>', function()
  local ok, vt = pcall(require, 'minuet.virtualtext')
  if ok and vt.action.is_visible() then
    vt.action.accept()
    return ''
  end
  return '\t'
end, { expr = true, silent = true })
```

当你重新启用 blink 时, 建议移除此全局 `<Tab>` expr 映射, 改走 blink 的内置链(见下)。

### 3) 可选：与 blink.cmp 集成(手动触发推荐)

官方示例支持把 Minuet 作为 blink 源：

```lua
require('blink-cmp').setup {
  keymap = {
    -- 手动拉起 minuet 源补全(不把 'minuet' 放进 sources.default)
    ['<A-y>'] = require('minuet').make_blink_map(),
  },
  sources = {
    -- default = { 'lsp', 'path', 'buffer', 'snippets', 'minuet' }, -- 不推荐直接加在 default
    providers = {
      minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        -- timeout 建议与 minuet.request_timeout 对齐(毫秒)
        timeout_ms = 3000,
        score_offset = 50, -- 如需在 PUM 里略微提高优先级
      },
    },
  },
  -- 避免不必要的请求
  completion = { trigger = { prefetch_on_insert = false } },
}
```

若需要把“AI 态优先、`<Tab>` 接受”并入 blink 的 `<Tab>` 链, 做法是在 blink 的 `<Tab>` 链首添加：

```lua
local ok, vt = pcall(require, 'minuet.virtualtext')
if ok and vt.action.is_visible() then vt.action.accept(); return end
```

从而实现：AI 态 → snippet 跳位 → PUM 导航 → Tabout 的短路顺序(参考 `completion/requirements.md`)。

### 4) 提供商与 API Key 配置(示例)

Minuet 支持多家与 OpenAI 兼容接口(OpenAI、Claude、Gemini、Ollama、llama.cpp 等)。示例：

```lua
require('minuet').setup {
  provider = 'openai_compatible',
  providers = {
    openai_compatible = {
      endpoint = 'https://api.openai.com/v1',
      -- 从环境变量读取：export OPENAI_API_KEY=...
      api_key_name = 'OPENAI_API_KEY',
      -- 可选：自定义模型
      model = 'gpt-4o-mini',
      -- 请求超时(秒)。与 blink 的 timeout_ms 对齐：timeout_ms = request_timeout * 1000
      request_timeout = 3,
      stream = true,
    },
    -- 也可配置 ollama / llama.cpp 等本地后端
    -- ollama = { endpoint = 'http://127.0.0.1:11434', name = 'Ollama', model = 'qwen2.5-coder:7b' },
  },
}
```

密钥安全：不要把 API Key 写进仓库配置, 使用环境变量或本地不纳入版本管理的机制。

### 5) 常见问题

- 觉得“行首/换行时有延迟”：若使用 nvim-cmp 作为前端, 增大 `fetching_timeout`；blink 前端可用 `async + timeout_ms`。
- PUM 总是被打扰：关闭 `virtualtext.auto_trigger_ft` 或仅在白名单文件类型开启；blink 侧关闭 `prefetch_on_insert`。
- `<Tab>` 出现“双动作”或被覆盖：检查是否仍保留了前述“全局 `<Tab>` expr 映射”；与 blink 的链路只能二选一。

### 6) 回归测试(对照 `completion/requirements.md`)

- AI 态(有虚拟文本)：`<Tab>` 接受；`<CR>` 正常回车；`<S-Tab>` 不用于 AI。
- 候选态(PUM 可见)：`<Tab>/<S-Tab>` 导航；`<CR>` 确认候选。
- 跳出态(成对符号边界)：`<Tab>`/`<S-Tab>` 触发 Tabout/TaboutBack；`<CR>` 正常换行。
- 普通态：`<Tab>/<S-Tab>` 按你的缩进/退格预期；`<CR>` 正常换行。

