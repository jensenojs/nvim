# Buffer 插件模块

意图: 缓冲区/标签页管理、会话持久化和光标位置记忆。

## 插件列表

### bufferline.lua
- 插件: `akinsho/bufferline.nvim`
- 仓库: https://github.com/akinsho/bufferline.nvim
- 功能: 缓冲区/标签栏，使用 tabs 模式模拟原生 tabline
- 配置特点:
  - 显示缓冲区图标和修改状态
  - 支持鼠标悬停预览
  - 可自定义分隔符样式和颜色图标

### lastplace.lua
- 插件: `ethanholz/nvim-lastplace`
- 仓库: https://github.com/ethanholz/nvim-lastplace
- 功能: 重新打开文件时记忆上次光标位置
- 配置特点:
  - 自动记忆光标位置
  - 支持特定文件类型和缓冲区类型的忽略列表
  - 支持打开文件时自动展开折叠

### persistence.lua
- 插件: `folke/persistence.nvim`
- 仓库: https://github.com/folke/persistence.nvim
- 功能: 自动保存session到文件中，在下次打开相同目录/项目时可以手动加载session恢复之前的工作状态
- 配置特点:
  - 提供快捷键用于恢复会话
  - 支持恢复当前目录会话和上次会话
  - 可以临时禁用会话保存

### reopen.lua
- 插件: `iamyoki/buffer-reopen.nvim`
- 仓库: https://github.com/iamyoki/buffer-reopen.nvim
- 功能: 重新打开最近关闭的缓冲区
- 配置特点:
  - 简单易用的缓冲区重新打开功能

## 使用说明

### Bufferline 使用说明

Bufferline 提供了现代化的缓冲区标签栏，具有以下特性：
- 显示文件图标和修改状态
- 支持鼠标操作（悬停预览、点击切换）
- 可自定义外观和行为

### Lastplace 使用说明

Lastplace 插件会在你重新打开文件时自动将光标定位到上次离开的位置，提高工作效率。

配置选项：
- `lastplace_ignore_buftype`: 忽略特定类型的缓冲区
- `lastplace_ignore_filetype`: 忽略特定文件类型的缓冲区
- `lastplace_open_folds`: 打开文件时自动展开折叠

### Persistence 使用说明

Persistence 插件提供了会话管理功能，可以保存当前的工作区状态并在下次打开时恢复。

快捷键：
- `<leader>pc`: 恢复当前目录下的session连接
- `<leader>pl`: 恢复上一次session连接
- `<leader>px`: 这次的会话不要在退出时保存

### Reopen 使用说明

Reopen 插件允许你快速重新打开最近关闭的缓冲区，类似于浏览器的"撤销关闭标签页"功能。