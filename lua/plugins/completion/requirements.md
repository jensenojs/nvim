# blink.cmp 自动补全需求梳理(仅需求, 不给解决方案)

本文档描述在你当前 Neovim 配置中, 引入并使用 blink.cmp 时, 对“自动补全体验”的完整诉求与约束。后续实现应严格以此为验收标准。

## 背景

- 当前环境：Neovim 0.11.x, 已启用 LSP, `lua/config/lsp/attach.lua` 存在对原生 `vim.lsp.completion` 的开启与按键习惯。
- 已存在插件：`tabout.nvim`(`lua/plugins/cursor/tabout.lua`), 需兼容其在“无补全弹窗时”的跳出行为。
- 目标插件：`saghen/blink.cmp` 作为唯一的补全前端, 后续可能引入 AI 源(通过 `blink.compat` 或官方兼容层)。

## 总体目标

- 用 blink.cmp “丝滑接管”原生补全, 使用户几乎无感知迁移。
- 在无补全候选时, 不破坏并保留 Tabout 的体验。
- 为未来的 AI 自动补全留好扩展位：以虚拟文本呈现, 且仅在“AI 建议存在”时用 <Tab> 接受该建议。

## 术语与状态判定

- PUM(popup menu)：补全候选弹窗是否可见(“候选态”)。
- AI Ghost Text：AI 建议以虚拟文本呈现(“AI 态”)。
- Pair Boundary：光标位于可跳出的成对符号边界(如 `()[]{}`、引号), 对应 Tabout 的“跳出态”。

## 交互优先级与行为规范

以下为 Insert 模式下按键在不同状态的优先级与行为, 优先级从高到低：

1) AI 态(存在 AI 虚拟文本)

- <Tab>：接受 AI 建议(仅此时如此)。
- <CR>：不接受 AI 建议, 执行默认回车(保持行内格式化由 LSP/format 决定)。
- <S-Tab>：不用于 AI, 按下视后续状态继续判定(见下)。

2) 候选态(PUM 可见)

- <Tab>/<S-Tab>：在候选项中前后选择。
- <CR>：确认当前选中候选；若无选中则按 blink 默认策略(可配置为确认首项或直接换行)。

3) 跳出态(无 PUM、无 AI, 且处于成对符号边界)

- <Tab>：走 Tabout 正向跳出(`<Plug>(Tabout)`)。
- <S-Tab>：走 Tabout 反向跳出(`<Plug>(TaboutBack)`)。
- <CR>：正常换行。

4) 普通态(上述都不满足)

- <Tab>/<S-Tab>：插入真实制表或回退到预期缩进行为(与个人缩进设置一致)。
- <CR>：正常换行。

备注：如果某态已处理按键, 后续态不再触发；实现时需严格保证“短路”顺序。

## 键位规范(Insert 模式)

- <Tab>：依据“优先级判定”依次执行：AI 接受 → PUM 下选择下一个 → Tabout → 插入 <Tab>。
- <S-Tab>：PUM 下选择上一个 → TaboutBack → 插入 <S-Tab>(或回退缩进)。
- <CR>：在 PUM 可见时确认；无 PUM 时正常换行；绝不用于接受 AI 虚拟文本。

## 源管理与排序要求

- 基础源：`lsp`、`path`、`snippets`、`buffer`。
- Lua 开发增强：`folke/lazydev.nvim` 的类型库联动(仅 Lua 文件), 确保 `lua_ls` 体验；不与 `neodev` 冲突。
- AI 源(未来引入)：
    - 通过 `blink.compat` 或官方兼容层接入(如 `codeium.nvim` 等)。
    - 以虚拟文本(ghost text)显示建议；需可配置开关与颜色高亮组。
    - 评分偏置：AI 建议不与常规 PUM 候选混淆(或置于兼容队列, 不干扰人类输入时机)。

## 与 LSP 原生补全的关系

- 需求：由 blink.cmp 完全接管补全生命周期与按键, 避免与 `vim.lsp.completion` 的重复触发或冲突。
- 表现：
    - 不出现“双重弹窗”。
    - 不出现 `<Tab>` 被多处映射争用的抖动。

## 与 Tabout 的协同

- 在“无 PUM、无 AI”场景, 保留 `tabout.nvim` 的正/反向跳出能力。
- 需与 blink 的按键映射做明确的 fallback 关系(见“交互优先级”)。

## 视觉与性能

- PUM 与文档浮窗：跟随当前 UI 风格(圆角、边框、zindex 与你现有 UI 一致)。
- 大文件或特定 filetype：支持禁用昂贵源(如 `buffer` 全量扫描), 或降级策略。
- 低延迟：首次触发补全不应卡顿；AI 源为异步, 不阻塞常规输入。

## 配置边界与文件职责(后续实施参考)

- `lua/plugins/completion/blink.lua`：blink 主配置(sources、keymap、ghost text、fallback 策略)。
- `lua/plugins/lang/lua.lua`：Lua 专项增强(lazydev, blink 源扩展/优先级调整)。
- `lua/config/lsp/attach.lua`：不再启用 `vim.lsp.completion.enable(...)`；保留 LSP 其他按键与 UI。
- `lua/plugins/cursor/tabout.lua`：维持现有配置；仅在“无 PUM、无 AI”时接管 `<Tab>/<S-Tab>`。

## 验收清单(必须全部满足)

- 键位行为按“交互优先级”逐项兑现, 包含 AI、PUM、Tabout、普通四态；冲突时以高优先级为准。
- Lua 文件中获得 lazydev 带来的补全质量提升(如 `vim.uv` 等符号)。
- 在无补全场景, `<Tab>`/`<S-Tab>` 能正确触发 Tabout；有补全时绝不误触 Tabout。
- AI 虚拟文本存在时, 只有 `<Tab>` 接受；`<CR>` 不接受。
- 不出现双弹窗、重复候选、按键抖动。
- 可通过开关禁用 AI 或个别源；各开关默认值有文档化说明。

## 开放问题(待确认)

- `<CR>` 在 PUM 可见且无显式选中项时的策略：确认首项 vs 直接回车(倾向与你当前习惯保持一致)。
- AI 提示的显示时机与长度限制：是否需要在 InsertHold 后延迟、是否限制最大行宽/多行截断。
- 大文件判定阈值与按 filetype 的默认禁用清单。

---
本文件仅为“需求与验收标准”, 不包含实现细节。后续实现变更如影响体验, 应先更新此文档再调整代码。
