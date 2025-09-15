# Cursor 插件模块

意图: 光标移动、文本对象、多光标编辑和包围符号操作。

## 插件列表

### flash.lua
- 插件: `folke/flash.nvim`
- 仓库: https://github.com/folke/flash.nvim
- 功能: 高效的光标移动插件，结合了easymotion和clever-f的功能
- 配置特点:
  - 支持Treesitter集成
  - 优化默认搜索体验
  - 提供内置的类似clever-f的功能

### nvim-surround.lua
- 插件: `kylechui/nvim-surround`
- 仓库: https://github.com/kylechui/nvim-surround
- 功能: 使用快捷键配合textobjects快速地添加/修改/删除各种包围符
- 配置特点:
  - 支持多种包围符 ((), [], {}, <>, '', "", ``等)
  - 提供别名简化操作 (b for (), r for [], B for {})
  - 支持自动跳转到插入位置

### tabout.lua
- 插件: `abecodes/tabout.nvim`
- 仓库: https://github.com/abecodes/tabout.nvim
- 功能: 在Insert模式下按<Tab>可以跳出括号
- 配置特点:
  - 与blink.cmp集成，统一处理<Tab>按键
  - 支持多种括号类型
  - 可配置为在无法跳出时执行缩进

### accelerated-jk.lua
- 插件: `rainbowhxch/accelerated-jk.nvim`
- 功能: 加速的jk移动，提供平滑滚动体验

### bookmarks.lua
- 插件: `tomasky/bookmarks.nvim`
- 功能: 书签管理，可以添加、删除和跳转书签

### comment.lua
- 插件: `numToStr/Comment.nvim`
- 功能: 代码注释工具，支持行注释和块注释

### nvim-various-textobjs.lua
- 插件: `chrisgrieser/nvim-various-textobjs`
- 功能: 提供额外的文本对象，增强编辑能力

### pairs.lua
- 插件: `windwp/nvim-autopairs`
- 功能: 自动配对符号，提高输入效率

### smarkyank.lua
- 插件: `gpanders/smarkyank.nvim`
- 功能: 高亮显示最近复制/剪切的文本

### vim-matchup.lua
- 插件: `andymass/vim-matchup`
- 功能: 增强%匹配功能，支持更多符号类型

### vim-visual-multi.lua
- 插件: `mg979/vim-visual-multi`
- 功能: 多光标编辑支持

## 使用说明

### Flash 使用说明

Flash 提供了高效的光标移动功能：
- `s`: easymotion风格的跳转
- `S`: 基于treesitter的块选中

### Surround 使用说明

Surround 提供了便捷的包围符操作：
- 添加包围符: `ys{motion}{char}`
- 删除包围符: `ds{char}`
- 修改包围符: `cs{old_char}{new_char}`

示例：
```
# 添加双引号包围单词
ysiww"     # 或 yss"

# 将括号改为方括号
csbr       # cs([

# 删除引号
ds"
```

### Tabout 使用说明

Tabout 允许你在插入模式下通过Tab键跳出括号：
- 在括号内按Tab键跳出到括号外
- 与补全菜单集成，避免冲突
- 支持自定义括号类型

### 插件间交互

这些插件协同工作以提供完整的光标操作体验：
1. Flash 用于快速跳转到特定位置
2. Surround 用于快速修改包围符
3. Tabout 用于快速跳出括号
4. 其他插件提供额外的光标移动和文本操作功能

所有插件都与Neovim的原生功能和其它插件良好集成，确保一致的用户体验。