# plugins 分类重组索引

目标: 在 tmp 沙箱中以“一个统一的 plugins 目录 + 主题子目录”的结构, 承载原仓库收集的插件意图, 先做需求归档与分层设计, 再按模块重写。

分类索引(仅归档来源, 暂不迁移实现):

- completion/: 补全引擎与片段
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/cmp.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/cmp-nvim-lsp.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/luasnip.lua`

- lsp/: LSP 生态(安装器/桥接等)
    - 原路径(目录): `/Users/jensen/.config/nvim/lua/plugins/ide/mason/`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/lsp-config.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/tiny-code-action.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/coc-nvim.lua` (作为 LSP 方案的替代路线归档)

- treesitter/: 语法树核心与周边
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/treesitter.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/treesitter-context.lua`

- diagnostics/: 问题列表/诊断面板
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/trouble.lua`

- git/: Git 集成
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/lazygit.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/git-signs.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/git-blame.lua`

- files/: 文件/搜索/预览/大文件
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/telescope.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/file-related/oil.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/file-related/yazi.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/file-related/grug-far.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/file-related/bigfile.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/filetype.lua`

- ui/: 视觉与交互 UI
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/which-key.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/aerial.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/bufferline.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/dropbar.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/focus.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/gruvbox.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/incline.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/indent-blankline.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/lualine.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/noice.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/rainbow.lua`

- cursor/: 光标/文本对象/多光标/包围
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/accelerated-jk.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/bookmarks.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/fetch.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/flash.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/nvim-surround.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/nvim-treesitter-textobjects.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/nvim-treesitter-textsubjects.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/nvim-various-textobjs.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/smarkyank.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/tabout.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/vim-matchup.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/cursor/vim-visual-multi.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/lastplace.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/comment.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/pairs.lua`

- format/: 格式化/静态修复
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/guard.lua`

- terminal/: 终端集成
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/terminal.lua`

- tasks/: 任务编排/构建器
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/overseer.lua`

- testing/: 测试生态
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/neotest.lua`

- session/: 会话/持久化
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/persistence.lua`

- input/: 输入法/输入增强
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/im_select.lua`

- dap/: 调试协议栈
    - 原路径(目录): `/Users/jensen/.config/nvim/lua/plugins/ide/dap/`
    - 原路径(目录): `/Users/jensen/.config/nvim/lua/plugins/ide/debug/`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/dap.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-ui.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-virtual-text.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/dap-repl-highlights.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/clients/python.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/clients/delve.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/dap/clients/codelldb.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/debug/debug.lua`

- ai/: AI 辅助
    - 原路径: 待补(如 copilot/codeium/llm 等, 迁移时登记)
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/copilot.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/copilotChat.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/codeium.lua`

- lang/: 语言生态(语言专属插件/增强, 与 lsp 解耦)
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/lang/go.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ide/coding/rustaceanvim.lua`
    - 原路径: `/Users/jensen/.config/nvim/lua/plugins/ui/markdown.lua`

使用说明:

- 仅记录来源与归类, 暂不迁移实现；后续按子目录逐个重写。
- 记录原路径是为了对照旧实现与保留语义。
- 最终加载器/DSL 风格会统一在 utils 中实现(后续补充)。

