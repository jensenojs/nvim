# Neovim 重构 TODO 列表与问题盘点

- 范围
    - 本清单覆盖当前配置在 `~/.config/nvim/` 下的已知问题、冲突、重构任务与决策点
    - 每个条目尽量精确到文件与行号, 便于实施

- 快速导航
    - 阻塞性错误与确定性修复
    - 冲突与冗余
    - 重构任务与目录调整
    - 依赖、在线/离线与健康检查
    - 决策项
    - 文档与教学

---

## 阻塞性错误与确定性修复

- `lua/core/options.lua:68` — shortmess 语法错误
    - 现状: `opt.shortmess = astWAIc` 非法字面量
    - 建议: 删除该行；使用 `opt.shortmess:append({ C = true, I = true, W = true, ... })` 按需配置
    - 参考: 同文件 `141-145` 已有 append, 避免冲突

- `lua/utils/quick_substitute.lua:72` — 模块返回调用结果而非函数/表
    - 现状: `return quick_substitute()` 导致 require 即执行且被缓存
    - 建议: 导出 `{ run = quick_substitute }` 或直接导出函数本身

- `lua/plugins/ide/coding/lsp-config.lua:13` — inlay hints API 使用不兼容
    - 现状: `vim.lsp.inlay_hint.enable(true, { bufnr })` 参数签名不规范
    - 建议: 特性检测 + 兼容封装, 如 `inlay.enable(true, { bufnr = bufnr })`, 并 `pcall` 保护

- `lua/plugins/ide/coding/lsp-config.lua:23` — 全局污染
    - 现状: `telescope_builtin = require("telescope.builtin")` 未加 `local`
    - 建议: `local telescope_builtin = require("telescope.builtin")`

- `lua/plugins/ide/coding/lsp-config.lua:153` — 隐式依赖次序风险
    - 现状: 直接 `require("cmp_nvim_lsp")`
    - 建议: 在本插件 spec 的 `dependencies` 增加 `"hrsh7th/cmp-nvim-lsp"` 保证装载顺序(即便后续默认使用 blink.cmp, 此处只用于扩展 capabilities, 可替代为内建能力检测)

## 冲突与冗余

- 输入法切换实现重复
    - `lua/core/autocmds.lua:18-45` 手写 im-select 调用
    - `lua/plugins/ide/im_select.lua` 使用 `keaising/im-select.nvim`
    - 建议: 二选一, 推荐保留插件方案, 删除手写 autocmd

- 旧补全/生态残留
    - `lua/plugins/ide/coding/coc-nvim.lua` 与原生 LSP/补全并存, 存在冲突风险
    - 建议: 隔离新配置时不引入该文件；旧配置保留但不再触达

- DAP 栈并不是当前目标
    - `lua/core/lazy.lua:42-44` 导入 `plugins.ide.dap`
    - 建议: 新配置不导入 DAP 相关 spec；旧配置不动

## 重构任务与目录调整

- 懒加载策略统一
    - `lua/core/lazy.lua:66-71` 现为 `defaults.lazy = false`
    - 建议: 新配置使用 `defaults.lazy = true`, 并为每插件标注 `event/ft/cmd/keys/cond`

- LSP 模块化
    - 拆分 `on_attach/capabilities/flags` 至 `lua/lsp/core.lua`
    - 语言服务器分别进入 `lua/lsp/servers/<name>.lua`
    - `lua/lsp/mason.lua` 统一 ensure_installed 并自动 setup

- 补全层抽象
    - 默认使用 `blink.cmp`, 在 `lua/plugins/completion/blink.lua` 提供 provider；保留 `nvim-cmp` 备选
    - 通过 `lua/core/feature_flags.lua` 切换 provider

- 目录重组建议
    - `lua/plugins/` 下分: `completion/`, `lsp/`, `treesitter/`, `files/`, `ui/`, `git/`, `diagnostics/`, `format/`, `cursor/`, `tools/`, `extras/`

## 依赖、在线/离线与健康检查

- 新增 `lua/core/env.lua`
    - `is_online()`, `has_cmd(bin)`, `is_mac/wsl/vscode`, `has_node/rg/...`

- 新增 `lua/health/user.lua`
    - 检查: im-select, ripgrep, node, treesitter, mason 可执行、LSP servers 路径等

- 懒加载条件
    - 使用 `cond = function() return require("core.env").has_cmd("rg") end` 等方式按依赖加载

## 决策项

- 输入法策略: 保留 `keaising/im-select.nvim` 或继续手写 autocmd? 推荐前者
- 补全 provider: 默认 `blink.cmp`, 保留 `nvim-cmp` 备选? 已同意采用 blink.cmp
- 格式化工具: 继续 `guard.nvim` 还是迁移 `conform.nvim`? 倾向于 `conform.nvim`
- 沙箱化方案: 采用 XDG + `NVIM_APPNAME=nv-blink` 的项目内隔离?

## 文档与教学

- 新增/已建文档
    - `study/gpt-5/0_lua_basics.md` — Lua 精华与 Neovim 配置实践
    - `study/gpt-5/0_lua_lazy_nvim_best_practices.md` — lazy.nvim 最佳实践
    - 待补: `study/gpt-5/0_lua_provider_design.md` — Completion Provider 抽象与 blink.cmp 对接
    - 待补: `study/gpt-5/0_lua_env_health.md` — 在线/离线策略与健康检查

- 参考资料
    - lazy.nvim: <https://github.com/folke/lazy.nvim>
    - 文档: <https://github.com/folke/lazy.nvim/blob/main/doc/lazy.nvim.txt>
    - 讨论(触发器): <https://github.com/folke/lazy.nvim/discussions/1713>
    - 讨论(opts vs config): <https://github.com/folke/lazy.nvim/discussions/1185>

---

# 执行顺序建议

- 优先: 修复“阻塞性错误与确定性修复”章节的 5 项
- 隔离: 在项目内创建 `nv-blink` 沙箱(不影响旧配置)
- 收敛: 移除旧补全与 DAP(仅限新配置), 设定 blink.cmp 为默认
- 模块化: LSP/补全/目录重组, 接入 env 与 health
- 回归: `:Lazy sync`, `:checkhealth`, 启动路径、Insert 补全、LSP attach
