# LSP × Telescope 键位接管：问题分析与时序保证

- 作者：临时记录(/lua/config/lsp/)
- 背景时间：2025-08-25 00:25 (+08)

---

## 1. 你的明确诉求(requirements)

- __不修改__ `lua/config/lsp/attach.lua` 的设计前提：该文件“不感知插件”, 负责在 `LspAttach` 时为当前 buffer 注入“基础、可退化”的 LSP 能力(含键位)。
- 当引入插件(如 `telescope.nvim`、`blink.cmp`/`nvim-cmp`)后, __由插件侧接管并覆盖对应键位__(符号查询、引用、补全选择/确认等), 且接管须在“LSP buffer 上”生效。
- 需要__精准说明__：为何当前 Telescope 的“接管”看似不生效；这是否与“加载顺序”还是“映射优先级/作用域”有关。
- 需要__给出时序保证__：如何在“不改 attach.lua”的前提下, 强制保证“插件的 buffer-local 键位覆盖 attach.lua 的 buffer-local 键位”, 避免数据竞争。

---

## 2. 现象与代码背景(context)

- `lua/config/lsp/attach.lua`
    - 在 `LspAttach` 中对当前 buffer 安装了大量 __buffer-local 映射__(例如 `<leader>o`→`vim.lsp.buf.document_symbol()`, `<leader>O`→`vim.lsp.buf.workspace_symbol()`)。
- `lua/plugins/fuzzy_finder/telescope.lua`
    - 文件顶部通过 `bind.nvim_load_mapping(keymaps)` 定义了 `<leader>o`/`<leader>O` 等 __全局映射__ 到 Telescope。
- `init.lua`
    - 先 `require("config.lsp.bootstrap")`, 再 `require("config.lazy")`。这意味着：attach 的 LSP 运行时初始化更早；Telescope 作为插件由 lazy.nvim 管理 __较晚__ 加载。

__表象__：在带 LSP 的 buffer 中, 按 `<leader>o`/`<leader>O` 并未触发 Telescope, 而是触发了内置 `vim.lsp.buf.*`。在无 LSP 的 buffer 中, 全局映射可用。

---

## 3. 根因(root cause)

- __优先级与作用域__：在 Neovim 中, __buffer-local 映射优先于全局映射__。当同一个按键在 buffer 里存在本地映射时, 会覆盖全局映射。因此：
    - `attach.lua` 在 `LspAttach` 发生时给当前 buffer 绑定了 `<leader>o`/`<leader>O`(buffer-local)。
    - `telescope.lua` 提供的是全局映射。
    - 结果：LSP buffer 上, buffer-local 覆盖全局, Telescope“看起来不生效”。

这与“谁先加载”关系不大；__只要__ buffer 上存在本地映射, 它就会覆盖全局映射。

---

## 4. 权威参考与链接(authoritative references)

- __Neovim 映射文档(map)__：
    - `<buffer>` 本地映射与清理：`:unmap <buffer>`, `:mapclear <buffer>`
    - 官方文档(HTML)：
        - Map 文档主页(含 1.2 SPECIAL ARGUMENTS, 介绍 `<buffer>`)：
            - <https://neovim.io/doc/user/map.html>
    - 文档源码(map.txt)：
        - <https://github.com/neovim/neovim/blob/master/runtime/doc/map.txt>
- __映射覆盖的经验事实(Issue 讨论)__：
    - Buffer-local 映射覆盖全局映射(具体案例)：
        - <https://github.com/neovim/neovim/issues/5645>
        - <https://github.com/neovim/neovim/issues/28022>
- __LSP 文档__：
    - 关于 `K` 的行为：“当存在自定义映射时, 默认 `hover` 映射不会生效”(说明用户映射优先)。
        - <https://neovim.io/doc/user/lsp.html>
- __自动命令(autocmd)执行顺序__：
    - 官方文档指出：匹配到的自动命令按你定义的顺序执行(后定义的在后执行)。
        - HTML： <https://neovim.io/doc/user/autocmd.html>
        - 源码： <https://github.com/neovim/neovim/blob/master/runtime/doc/autocmd.txt>

> 归纳：综合以上文档与 issue, 可推断“buffer-local > global”的覆盖关系, 以及“后定义的自动命令在后执行”的顺序语义。

---

## 5. 你的需求下的“数据竞争”具体体现

- __参与方__：
    - `attach.lua` 的 `LspAttach` 回调：为“新附加 LSP 的 buffer”定义 __buffer-local__ 键位(更高优先级)。
    - `telescope.lua` 的全局映射：为所有 buffer 定义 __全局__ 键位(较低优先级)。
- __竞争点__：当某个 buffer 发生 LSP 附加时, `attach.lua` 的本地映射会覆盖 Telescope 的全局映射；若你想让 Telescope 接管该 buffer, 必须确保 __在该 buffer 上__ 再设置一次 __buffer-local__ 映射, 并且该设置动作发生在 `attach.lua` 之后(同事件的后续回调, 或后续时机)。

---

## 6. 解决方案(概述, 不改 attach.lua)

> 目标：保持 `attach.lua` 的“可退化”与“插件无感”, 同时保证插件在 LSP buffer 上覆盖同名键位。

- __方案 A(推荐)：插件侧注册 `LspAttach` 自动命令, 设置 buffer-local 键位__
    - 在 `telescope.lua` 的 `config()` 中注册 `autocmd LspAttach`；在回调里对 `ev.buf` 设置 `<leader>o`/`<leader>O` 的 __buffer-local__ 映射到 Telescope 的入口。
    - __顺序保证__：`attach.lua` 的自动命令更早定义, 插件稍后被 lazy.nvim 加载并定义自己的自动命令；同一 `LspAttach` 事件触发时, __后定义__ 的自动命令 __后执行__, 因此插件能覆盖前者。
    - __已附加的 buffer 覆盖问题__：如果插件在某些 buffer 已经 LSP 附加之后才加载, 单纯监听未来的 `LspAttach` 是不够的。需要在插件 `config()` 启动时：
        - 遍历当前 `vim.lsp.get_clients()` 与其已附加的 `bufnr`, 为这些 buffer 立即补上 buffer-local 映射；或
        - 额外注册 `BufEnter` 针对已附加 LSP 的 buffer 进行覆盖。

- __方案 B：插件在 LspAttach 时先 `:unmap <buffer>` 再绑定__
    - 显式清理 `attach.lua` 的同名按键, 再设置自己的 buffer-local 映射。功能等价于 A, 但更直观。

- __方案 C：lazy.nvim 的事件式加载__
    - 将 Telescope 的“接管逻辑”放入 lazy.nvim 的 `event = "LspAttach"`, 并在加载后 __立即__ 为 `ev.buf` 绑定(或配套一个 `autocmd LspAttach`)。
    - 仍需照顾“插件加载时已有已附加 buffer”的情况(同 A 的兜底方法)。

- __方案 D：以 `BufEnter` 做兜底__
    - 在 `BufEnter` 中检测该 buffer 是否已附加 LSP(`vim.lsp.get_clients({ bufnr = ev.buf })` 非空), 若是则覆盖键位。
    - 优点：补齐所有晚加载场景；缺点：需避免频繁重复设置(可用 buffer 变量幂等标记)。

> 关键共识：没有“映射优先级”的显式权重参数；__只能__靠“作用域(buffer-local vs global)”与“定义顺序(autocmd 定义顺序与执行顺序)”来实现覆盖。

---

## 7. 时序保证方式(如何“强制保证先后顺序”)

- __利用定义顺序__：
    - 让 `attach.lua` 在 `init.lua` 早期加载(你当前已如此)。
    - 让插件(Telescope/blink)由 lazy.nvim __稍后__ 加载, 然后在其 `config()` 内 __再__ 注册 `LspAttach`/`BufEnter` 的自动命令(这一步骤的自动命令“定义”就比 `attach.lua` 晚)。
    - 根据 `:h autocmd`：匹配到的自动命令按定义顺序执行, 故插件侧回调会在 `attach.lua` 回调之后执行, 从而覆盖同名 buffer-local 键位。

- __覆盖已存在的附加状态__：
    - 插件加载瞬间, 可能已经有部分 buffer 附加了 LSP, 这些 buffer 不会再触发一次 `LspAttach`。
    - 解决：插件在 `config()` 里主动遍历现有附加关系为这些 buffer 绑定；或注册 `BufEnter` 兜底一次。

- __lazy.nvim 的依赖/优先级__：
    - 你也可以声明插件间的 `dependencies` 或使用 `priority`、`event` 来约束加载时机, 但本问题的本质在于“__相同事件下的回调定义顺序与 buffer-local 覆盖__”。只要插件__在 attach.lua 之后定义__了自己的 `LspAttach`/`BufEnter` 回调, 并在回调中 __设置 buffer-local 映射__, 就能实现稳定覆盖。

---

## 8. 总结(takeaways)

- __核心事实__：buffer-local 映射会覆盖全局映射；自动命令按定义顺序执行(后定义后执行)。
- __症结__：`attach.lua` 在 LspAttach 时给 buffer 设了本地键位, 覆盖了 Telescope 的全局键位, 故“接管不生效”。
- __方向__：不改 attach.lua 的前提下, 让插件侧在“同一 buffer 上、稍后时机”安装自己的 __buffer-local__ 键位, 并处理“插件加载时已存在的 LSP buffer”这一边界。
- __可验证性__：参考文档与 issue 具有权威佐证；按“方案 A + 兜底遍历/BufEnter”实现后, LSP buffer 上的 `<leader>o`/`<leader>O` 应稳定触发 Telescope；非 LSP buffer 则仍使用插件的全局映射作为兜底。
