# git

意图: Git 集成与 UI。

原路径映射:

- /Users/jensen/.config/nvim/lua/plugins/ide/lazygit.lua
- /Users/jensen/.config/nvim/lua/plugins/ui/git-signs.lua
- /Users/jensen/.config/nvim/lua/plugins/ui/git-blame.lua

- git-blame: 当前行虚拟文本 Blame 信息。
    - 触发: `event = "VeryLazy"`
    - 仓库: <https://github.com/f-person/git-blame.nvim>
    - 配置: `lua/plugins/ui/git-blame.lua`

- gitsigns: Git 变更标记/导航/操作(TODO : 快捷键思考, which-key 分组考虑引入)
    - 触发: `event = {"BufReadPre", "BufNewFile"}`
    - 仓库: <https://github.com/lewis6991/gitsigns.nvim>
    - 配置: `lua/plugins/ui/gitsigns.lua`
