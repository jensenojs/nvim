# 使用指南

- 大纲
    - 这部分讨论: 插件各自的能力、现成的键位怎么用、它们如何协作、常见工作流、权衡与参考链接
    - 可视化: mermaid 结构图、ascii-tree 调用路径

## 组合概览

这套 treesitter 组合已经配置好, 可以直接用:

- nvim-treesitter: 解析语法树, 提供高亮/折叠/增量选择等核心能力。
    - 配置: `lua/plugins/treesitter/treesitter.lua` 中 `opts.highlight`、自动折叠初始化见(33-60), 应用配置见(61-63)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter>
- nvim-treesitter-textobjects: 基于查询的选择/跳转/交换/LSP 互操作。
    - 配置: `lua/plugins/treesitter/treesitter-textobjects.lua` 的 `opts` 与 `config()`(61-84)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter-textobjects>
- nvim-treesitter-textsubjects: 基于光标位置的“智能/容器内外”选择, 降低记忆成本。
    - 配置: `lua/plugins/treesitter/treesitter-textsubjects.lua` 的 `opts`(7-17)
    - 仓库: <https://github.com/RRethy/nvim-treesitter-textsubjects>
- nvim-treesitter-context: 窗口顶部显示当前语法上下文, 聚焦所在函数/类头部。
    - 说明: 本仓库保持默认行为; 如需自定义, 取消注释 `treesitter-context.lua` 的 `setup()`(15-17)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter-context>

```mermaid
flowchart LR
  K[按键输入] -->|af/if/ac/...| TO[textobjects.select]
  K -->|]m [[ ]M [M ...| TO_MOVE[textobjects.move]
  K -->|; ,| TO_REPEAT[repeatable_move]
  K -->|g; gi; .| TSUB[textsubjects]
  Parser[nvim-treesitter 解析器] -->|queries| TO & TSUB
  View[treesitter-context 顶部上下文] --> UI
  TO & TSUB --> UI[编辑器状态: 选区/光标/跳转]
```

## 键位与用法

- textobjects.select
    - `af`/`if`: 选择函数(外/内)。`treesitter-textobjects.lua`(13-14)
    - `ac`/`ic`: 选择类(外/内)。`treesitter-textobjects.lua`(15-16)
    - `as`: 选择语言作用域(scope)。`treesitter-textobjects.lua`(17)
    - `ad`/`id`: 选择条件语句(外/内)。`treesitter-textobjects.lua`(18-19)
    - 选择模式: 函数按行、类按块等。`treesitter-textobjects.lua`(21-25)

- textobjects.move
    - `]m`/`[m`: 到函数起始/上一个。`treesitter-textobjects.lua`(33,44)
    - `]]`/`[[` 与 `][`/`[]`: 到类开始/结束/上一个/下一个。`treesitter-textobjects.lua`(34-45,39-49)
    - `]o`: 到循环; `]s`: 到作用域; `]z`: 到折叠。`treesitter-textobjects.lua`(35-37)
    - `]d`/`[d`: 在条件间跳转。`treesitter-textobjects.lua`(51-52)

- textobjects.repeatable_move
    - `;`: 重复上一次语义跳转(向前)。`,`: 向后。绑定见 `treesitter-textobjects.lua`(70-80)

- textobjects.swap(默认关闭)
    - `<leader>a`/`<leader>A`: 交换参数(下一个/上一个)。`treesitter-textobjects.lua`(55-58)

- textsubjects(与 select 互补, 更“就近/智能”)
    - `.`: 智能选择(根据语境挑最相关)。`treesitter-textsubjects.lua`(11)
    - `g;`: 选择容器(外)。`treesitter-textsubjects.lua`(15)
    - `gi;`: 选择容器(内)。`treesitter-textsubjects.lua`(16)
    - 提示: 默认的 `;`/`i;` 已改为 `g;`/`gi;` 以避开可重复移动的 `;`/`,` 冲突。

- treesitter-context
    - 自动显示语法上下文行; 默认配置即可使用。
    - 若要细化(如 max_lines/分隔线), 取消注释 `treesitter-context.lua` 的 `setup()`(15-17)

## 执行流与调用路径

- 调用路径

```
treesitter.lua (config) ──▶ require("nvim-treesitter.configs").setup(opts)   # treesitter.lua(61-63)
                                                 │
                                                 ├─ highlight/indent/fold...
                                                 └─ matchup

treesitter-textobjects.lua ──▶ configs.setup({ textobjects = opts })          # textobjects.lua(61-64)
                              └─ 绑定 ; , 可重复移动                         # textobjects.lua(70-80)

treesitter-textsubjects.lua ──▶ configs.setup({ textsubjects = opts })        # textsubjects.lua(19-21)

treesitter-context.lua ──▶ 默认生效; 如需 opts, 调用 setup(opts)              # context.lua(15-17 注释)
```

- 折叠自动化
    - 首次读入 buffer 时, 当解析器可用且文件不大时启用 expr 折叠并设置 `foldlevel=10`。
    - 触发逻辑: `treesitter.lua` 的 `init()` 自动命令组, 见(33-60)

## 常见操作流

- 粗选容器 → 细化内容
    - g; 选函数/类外层 → gi; 进入内部 → . 智能微调选区

- 语义跳转 → 重复
    - 先用 ]m/[[/]] 等跳转 → `;`/`,` 重复上次方向

- 参数重排(需手动启用 swap)
    - 开启 `swap.enable=true` 后, 用 `<leader>a`/`<leader>A` 在参数间调序

## 设计取舍与注意

- 键位冲突的平衡
    - 我们将 textsubjects 默认的 `;`/`i;` 改为 `g;`/`gi;`, 把 `;`/`,` 让给 repeatable_move, 实现“所有语义跳转都可重复”。
    - `,` 在 textobjects.repeat 与 textsubjects.prev_selection 都有用途。当前两者并存, 若出现冲突可在 `treesitter-textsubjects.lua` 改 `prev_selection`(9) 或将其置空禁用。

- 状态与能力边界
    - textobjects 面向命名节点, 需要你知道“大概想要什么对象”。textsubjects 倾向“就近选你想要的”。
    - 两者组合: 先粗定位(跳转/容器), 再智能细化(智能/内层)。

## 参考链接

- nvim-treesitter: <https://github.com/nvim-treesitter/nvim-treesitter>
- textobjects: <https://github.com/nvim-treesitter/nvim-treesitter-textobjects>
- textsubjects: <https://github.com/RRethy/nvim-treesitter-textsubjects>
- treesitter-context: <https://github.com/nvim-treesitter/nvim-treesitter-context>
