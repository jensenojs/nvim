# Neovim 配置重构：初步行动计划(结合 GPT-5 设计与 Qwen 评估)

根据对 `@study/gpt-5` 提出的设计规范和 `@study/qwen` 生成的现状评估的综合分析, 以下是建议的 Neovim 配置重构初步行动计划。此计划旨在结合两者的优势, 从解决最紧迫的问题入手, 逐步向更现代化、模块化的架构演进。

## 阶段一：清理与准备 (基于 Qwen 评估)

此阶段的目标是解决当前配置中的混乱和冲突, 为后续的现代化重构奠定一个干净的基础。

**行动项:**

1. **立即备份**: 在进行任何更改前, 完整备份 `.config/nvim` 目录。
2. **移除 `coc-nvim`**:
    * 删除 `lua/plugins/ide/coding/coc-nvim.lua` 文件。
    * 检查 `lua/core/keymaps.lua` 和 `lua/plugins/ide/coding/lsp-config.lua` 中是否有残留的与 `coc-nvim` 相关的键位映射或逻辑, 并彻底移除。
    * 确保 `lua/core/lazy.lua` 中没有对 `coc-nvim` 的任何引用。
3. **移除 DAP**:
    * 删除 `lua/plugins/ide/dap/` 整个目录。
    * 检查 `lua/core/lazy.lua` 中 `import = "plugins.ide.dap"` 的条目并移除。
    * 移除所有与 DAP 相关的键位映射(如 `F5`, `F9` 等)。
4. **修复已知阻塞性错误** (参考 GPT-5 TODO):
    * 修复 `lua/core/options.lua` 中的 `shortmess` 语法错误。
    * 修复 `lua/utils/quick_substitute.lua` 的模块返回问题。
    * 修复 `lua/plugins/ide/coding/lsp-config.lua` 中的 `telescope_builtin` 全局污染问题。
    * (可选, 但推荐) 解决 `lua/plugins/ide/coding/lsp-config.lua` 中的 inlay hints API 兼容性问题。

## 阶段二：核心功能稳定 (基于 Qwen 评估与 GPT-5 设计)

在清理了旧有混乱后, 巩固并优化核心功能——LSP 和补全系统。此阶段开始引入 GPT-5 的设计理念。

**行动项:**

1. **巩固 `nvim-lspconfig`**:
    * 保留并优化 `lua/plugins/ide/coding/lsp-config.lua`。
    * 确保所有 LSP 相关的键位映射(`gd`, `gr`, `<leader>rn` 等)都正确指向 `nvim-lspconfig` 提供的功能。
2. **决策：补全引擎**:
    * **选项 A (采纳 GPT-5 建议 - 推荐)**:
        * 调研并决定采用 `blink.cmp` 作为新的默认补全引擎。
        * 移除 `lua/plugins/ide/coding/cmp.lua`。
        * 创建新的 `lua/plugins/completion/blink.lua` (或类似路径, 为后续模块化做准备) 来配置 `blink.cmp`。
        * 配置 `blink.cmp` 与 `nvim-lspconfig`、`luasnip` 等的集成。
    * **选项 B (渐进式 - 备选)**:
        * 如果对 `blink.cmp` 不熟悉或想先求稳定, 可以先优化现有的 `nvim-cmp`。
        * 保留 `lua/plugins/ide/coding/cmp.lua`, 但进行清理和优化。
        * 确保 `copilot.lua` 和 `copilot-cmp` (或等效插件) 配置正确。
        * 移除对 `codeium` 的任何引用。
        * **注意**: 无论选择哪个选项, 都必须确保完全移除了 `coc-nvim` 的影响。
3. **激活 GitHub Copilot**:
    * 确保 `copilot.lua` 插件已正确配置并安装。
    * 将其集成到你选择的补全引擎(`blink.cmp` 或 `nvim-cmp`)中。

## 阶段三：迈向模块化与现代化 (采纳 GPT-5 设计)

此阶段是重构的核心, 目标是按照 GPT-5 提出的现代化架构重组配置。

**行动项:**

1. **创建基础环境检测模块**:
    * 创建 `lua/core/env.lua`。
    * 实现 `is_online()`, `has_cmd(bin)` 等函数, 用于后续的条件加载。
2. **重构 `lazy.nvim` 配置**:
    * 修改 `lua/core/lazy.lua`:
        * 将 `defaults.lazy = false` 改为 `defaults.lazy = true`。
        * 根据 GPT-5 的建议和实际需求, 为每个插件明确添加 `event`, `ft`, `cmd`, `keys`, `cond` 等懒加载触发条件。
        * (可选) 考虑为联网插件添加 `cond = function() return require("core.env").is_online() end`。
3. **开始目录结构重组**:
    * **谨慎进行**: 这是一个较大的改动, 建议逐步进行。
    * 参考 GPT-5 的建议, 开始创建新的目录结构, 例如：
        * `lua/plugins/lsp/` (用于存放 LSP 相关的 `on_attach`, `capabilities`, 以及各语言服务器的独立配置 `servers/<name>.lua`)。
        * `lua/plugins/completion/` (用于存放补全引擎配置, 如 `blink.lua` 或 `cmp.lua`)。
        * `lua/plugins/editor/` (可以存放 `treesitter`, `telescope`, `which-key` 等增强编辑体验的插件)。
        * `lua/plugins/ui/` (存放主题、状态栏、缓冲区栏等 UI 相关插件)。
    * 将现有插件配置逐步迁移到新的目录结构中, 并更新 `lua/core/lazy.lua` 中的 `import` 路径。
4. **实现用户自定义健康检查**:
    * 创建 `lua/health/user.lua`。
    * 添加对关键依赖(如 `rg`, `node`, `im-select`)和 LSP 服务器路径的检查。

## 阶段四：持续优化与文档化 (采纳 GPT-5 设计与 Qwen 建议)

重构是一个持续的过程, 此阶段关注于提升配置的健壮性、可维护性和自解释性。

**行动项:**

1. **增强注释与文档**:
    * 在复杂的配置块中添加清晰的注释。
    * (采纳 GPT-5 建议) 考虑创建或补充类似 `study/gpt-5/` 中的文档, 记录你的配置决策、模块设计和最佳实践。
2. **标准化命名与代码风格**:
    * 确保模块文件名、函数名、变量名具有描述性且风格统一。
3. **性能调优**:
    * 运行 `:Lazy profile` 分析启动性能瓶颈。
    * 根据分析结果调整懒加载策略或插件配置。
4. **回归测试**:
    * 定期运行 `:checkhealth` 确保所有组件状态良好。
    * 测试核心功能(LSP、补全、文件浏览、Git 集成等)是否正常工作。

## 总结

这个初步行动计划结合了对现状的准确评估和对未来架构的清晰规划。它提供了一个从清理、稳定到现代化、优化的清晰路径。用户可以根据自己的节奏和偏好, 逐步执行这些步骤, 最终将 Neovim 配置重构为一个强大、清晰、易于维护的个性化开发环境。
