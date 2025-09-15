# Neovim Configuration Context

## Project Overview

This is a comprehensive Neovim configuration designed for software development with a focus on modern plugin management, LSP integration, and efficient workflow patterns. The configuration follows the "buffer-centric" approach to file management rather than the traditional tab-based approach of most IDEs.

### Key Principles

1.  **Buffer-Centric Workflow**: Uses buffers as proxies for files rather than relying on tabs, which aligns with Vim's design philosophy
2.  **Lazy Loading**: Uses lazy.nvim for efficient plugin management and loading
3.  **LSP Integration**: Full Language Server Protocol support with Mason for tool management
4.  **Modular Organization**: Configuration is organized into logical modules for maintainability

## Directory Structure

```
.
├── init.lua                 # Main entry point
├── lazy-lock.json
├── QWEN.md                  # This file
├── todo.md
├── docs/                    # Documentation
│   ├── dap.md
│   ├── lazy_nvim_best_practices.md
│   ├── README.md
│   └── study/
├── lsp/                     # LSP server configurations
│   ├── 多LSP共存.md
│   ├── bashls.lua
│   ├── clangd.lua
│   ├── doc-zh-CN-translation.txt
│   ├── golangci_lint_ls.lua
│   └── ...
├── lua/
│   ├── config/              # Core configuration modules
│   │   ├── debug/           # DAP configurations
│   │   ├── lsp/             # LSP configurations
│   │   ├── autocmds.lua
│   │   ├── environment.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   ├── options.lua
│   │   └── quick_substitute.lua
│   ├── plugins/             # Plugin specifications
│   │   ├── ai/              # AI-related plugins
│   │   ├── buffer/          # Buffer management
│   │   ├── completion/      # Completion engines
│   │   ├── cursor/          # Cursor movement and text objects
│   │   ├── diagnostics/     # Diagnostics and DAP
│   │   ├── file/            # File browsing and searching (yazi, grug-far, bigfile)
│   │   ├── format/          # Code formatting
│   │   ├── fuzzy_finder/    # Fuzzy finding (Telescope)
│   │   ├── git/             # Git integration
│   │   ├── input/           # Input method
│   │   ├── lang/            # Language-specific plugins
│   │   ├── mason/           # Mason for tool management
│   │   ├── tasks/           # Task management
│   │   ├── terminal/        # Terminal integration
│   │   ├── test/            # Testing
│   │   ├── treesitter/      # Treesitter syntax highlighting
│   │   └── ui/              # User interface enhancements
│   └── utils/               # Utility functions
└── snippets/                # Code snippets
```

## Core Configuration

### Entry Point: init.lua
The main configuration file that loads all modules in order:
1.  Environment setup
2.  Keymaps
3.  Options
4.  Autocommands
5.  LSP bootstrap
6.  Lazy plugin management

### Key Features

#### Buffer Management
-   Uses Shift+H/Shift+L to navigate between buffers
-   Smart buffer closing (quits if only one buffer remains)
-   Buffer-centric workflow instead of tab-based navigation

#### Window Management
-   Ctrl+Shift+H/J/K/L for window navigation
-   Proper split handling with splitright/splitbelow

#### LSP Integration
-   Mason for automatic tool installation
-   Support for multiple languages (Go, Rust, Python, C/C++, Lua, etc.)
-   Custom LSP configurations in the `lsp/` directory
-   LSP keymaps are overridden by Telescope for a unified UI experience where applicable

## Plugin Management

### System: lazy.nvim
Plugins are organized in the `lua/plugins/` directory by category:
-   `ai/` - AI coding assistants (minuet)
-   `buffer/` - Buffer management (bufferline)
-   `completion/` - Autocompletion engines (blink.cmp)
-   `cursor/` - Cursor movement and text objects (flash, tabout)
-   `diagnostics/` - DAP for debugging
-   `file/` - File browsing and searching (yazi, grug-far, bigfile)
-   `format/` - Code formatting (conform)
-   `fuzzy_finder/` - Fuzzy finding (Telescope)
-   `git/` - Git integration (gitsigns, lazygit)
-   `input/` - Input method (im_select)
-   `lang/` - Language-specific plugins (rustaceanvim, markdown)
-   `mason/` - Mason for tool management
-   `tasks/` - Task management
-   `terminal/` - Terminal integration (toggleterm)
-   `test/` - Testing
-   `treesitter/` - Treesitter syntax highlighting
-   `ui/` - User interface enhancements (lualine, which-key, indent-blankline)

## Language Support

### Supported Languages
-   **Go**: gopls, golangci-lint, delve (debugging)
-   **Rust**: rust-analyzer (via rustaceanvim), codelldb (debugging)
-   **Python**: pyright, ruff
-   **C/C++**: clangd, codelldb (debugging)
-   **Lua**: lua-language-server
-   **Shell**: bash-language-server
-   **JSON**: jsonls
-   **YAML**: yamlls

### DAP
-   Debug Adapter Protocol (DAP) support for Go, C/C++, Rust
-   Integrated debugging UI with variable inspection
-   Breakpoint management and step debugging
-   Language-specific debugging configurations via `config/debug/` and dedicated plugins like `nvim-dap-go`

### DAP Configuration
Debugging support is provided through the Debug Adapter Protocol (DAP) with language-specific adapters:
-   **Go**: Delve debugger (via `nvim-dap-go`)
-   **C/C++/Rust**: CodeLLDB

## Keymaps

### Navigation
-   `Space` - Leader key
-   `Shift+H`/`Shift+L` - Previous/next buffer
-   `Ctrl+Shift+H/J/K/L` - Window navigation

### File Operations
-   `Leader+q` - Close buffer or quit if last buffer
-   `Leader+w` - Save current buffer
-   `Leader+W` - Save all buffers
-   `Leader+Q` - Force quit

### Search
-   `/` - Fuzzy search within the current buffer (Telescope `current_buffer_fuzzy_find`)
-   `Leader+/` - Live grep across the project (Telescope `live_grep`)
-   `Ctrl+p` - Find files (Telescope `find_files`)

### DAP (Debug Adapter Protocol)
-   F5 - Continue execution
-   F7 - Toggle DAP UI
-   F9 - Toggle breakpoint
-   F10 - Step over
-   F11 - Step into
-   F12 - Step out

### Terminal
-   `Ctrl+\` - Toggle default terminal
-   `Ctrl+Shift+P` - Toggle btop terminal (if btop is installed)
-   `Ctrl+Shift+Q` - Toggle qwen terminal (if qwen is installed)

### Formatting
-   `Leader+f` - Format only modified lines
-   `Leader+F` - Format entire buffer

## Development Environment

### Mason Tools
Automatically installs and manages:
-   LSP servers for all supported languages
-   Linters and formatters (stylua, black, ruff, etc.)
-   Debug adapters (delve, codelldb)

### Custom Utilities
The `utils/` directory contains custom helper modules:
-   `bind.lua` - Keymap DSL
-   `mason-list.lua` - Tool and server management lists
-   `dap.lua` - Debug adapter configuration helpers
-   `icons.lua` - Icon management

## Building and Running

### Setup Commands
1.  Start Neovim: `nvim`
2.  Plugins will be automatically installed on first run
3.  LSP servers will be automatically installed via Mason

### Custom Commands
-   `:LspInfo` - Check LSP health
-   `:LspLog` - View LSP logs
-   `:LspRestart [server]` - Restart specific LSP server
-   `:ConformInfo` - Check formatter status
-   `:FormatToggle` - Toggle auto-format-on-save globally or for buffer
-   `:Mason` - Open Mason tool installer UI

## Development Conventions

### Configuration Philosophy
-   Modular organization with clear separation of concerns
-   Buffer-centric workflow over tab-based navigation
-   Lazy loading for performance
-   Extensive use of Neovim's built-in features

### Keymap Conventions
-   Leader key is Space
-   Descriptive keymap descriptions for all mappings
-   Consistent naming patterns for custom commands

### Plugin Organization
-   Plugins organized by functionality rather than author
-   README files explaining plugin categorization
-   Clear separation between configuration and plugin specs

## Workflow Patterns

### File Management
-   Buffers represent files, not tabs
-   Smart buffer switching with minimal keypresses
-   Fuzzy finding for files and content

### Code Editing
-   LSP-powered completions and diagnostics
-   Treesitter-based syntax highlighting
-   Integrated formatting and linting

### Navigation
-   Efficient buffer switching
-   Window management without tabs
-   Fuzzy finding for files, buffers, and symbols

### Search
-   `/` maps to Telescope's `current_buffer_fuzzy_find`, replacing native search
-   `Leader+/` maps to Telescope's `live_grep` for project-wide search

### Debugging
-   Unified DAP setup for multiple languages
-   UI integrated via `nvim-dap-ui`

## Customization Points

### Adding New Languages
1.  Add LSP server and tools to `utils/mason-list.lua`
2.  Create configuration file in `lsp/` directory if needed
3.  Add language-specific plugin if needed (e.g., in `lua/plugins/lang/`)
4.  Add DAP configuration in `config/debug/` if debugging is needed

### Adding New Plugins
1.  Create plugin specification in appropriate category under `lua/plugins/`
2.  Lazy will automatically load it

### Custom Keymaps
1.  Add to `lua/config/keymaps.lua`
2.  Use the `bind` utility for consistent keymap definitions

## Troubleshooting

### Common Issues
-   If LSP servers aren't working, check `:LspInfo`
-   If plugins aren't loading, check with `:Lazy`
-   For performance issues, check startup time with `:StartupTime`

### Logs
-   LSP logs: `:LspLog`
-   General Neovim logs: Check `stdpath('log')`
-   Mason logs: Check `:MasonLog`