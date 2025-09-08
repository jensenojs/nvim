# ui

意图: 视觉与交互 UI。

## 插件目录与触发

为每个 UI 插件提供: 用途、懒加载触发与仓库链接, 便于维护与排错。

- gruvbox: 主题与高亮, 避免懒加载以杜绝闪烁。
    - 触发: `lazy = false`, `priority = 1000`
    - 仓库: <https://github.com/ellisonleao/gruvbox.nvim>
    - 配置: `lua/plugins/ui/gruvbox.lua`

- satellite: 装饰滚动条。
    - 触发: `event = "VeryLazy"`
    - 仓库: <https://github.com/lewis6991/satellite.nvim>
    - 配置: `lua/plugins/ui/satellite.lua`

- lualine: 状态栏, 主题与分段可配置。
    - 触发: `event = "VeryLazy"`
    - 备注: 主题 `gruvbox_light`, 集成 `copilot-lualine`
    - 仓库: <https://github.com/nvim-lualine/lualine.nvim>
    - 配置: `lua/plugins/ui/lualine.lua`

- indent-blankline(ibl): 缩进指引线。
    - 触发: `event = "VeryLazy"`
    - 备注: 在 `init` 中设置 `termguicolors` 与简易高亮组
    - 仓库: <https://github.com/lukas-reineke/indent-blankline.nvim>
    - 配置: `lua/plugins/ui/indent-blankline.lua`

- dropbar: Winbar 面包屑导航, IDE 风格。
    - 触发: `event = "VeryLazy"`
    - 依赖: `telescope-fzf-native`(可选, `build = "make"`)
    - 仓库: <https://github.com/Bekaboo/dropbar.nvim>
    - 配置: `lua/plugins/ui/dropbar.lua`

- focus: 自动聚焦/调整 split 尺寸。
    - 触发: `event = "VeryLazy"`
    - 备注: 通过 `autocmd` 忽略特定 `buftype/filetype`
    - 仓库: <https://github.com/nvim-focus/focus.nvim>
    - 配置: `lua/plugins/ui/focus.lua`

- incline: 浮动 window 状态栏/标签。
    - 触发: `event = "VeryLazy"`
    - 仓库: <https://github.com/b0o/incline.nvim>
    - 配置: `lua/plugins/ui/incline.lua`

- rainbow-delimiters: 括号/分隔符彩虹高亮。
    - 触发: `event = "VeryLazy"`
    - 仓库: <https://github.com/HiPhish/rainbow-delimiters.nvim>
    - 配置: `lua/plugins/ui/rainbow.lua`

- noice: 现代化 cmdline/消息/LSP UI。
    - 触发: `event = "VeryLazy"`
    - 依赖: `nui.nvim`, `nvim-web-devicons`, 可选 `nvim-notify`
    - 仓库: <https://github.com/folke/noice.nvim>
    - 配置: `lua/plugins/ui/noice.lua`

- which-key: 快捷键提示。
    - 触发: `event = "VeryLazy"`
    - 仓库: <https://github.com/folke/which-key.nvim>
    - 配置: `lua/plugins/ui/which-key.lua`
