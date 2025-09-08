# Neovim Configuration Context

## Project Overview

This is a comprehensive Neovim configuration designed for software development with a focus on modern plugin management, LSP integration, and efficient workflow patterns. The configuration follows the "buffer-centric" approach to file management rather than the traditional tab-based approach of most IDEs.

### Key Principles

1. **Buffer-Centric Workflow**: Uses buffers as proxies for files rather than relying on tabs, which aligns with Vim's design philosophy
2. **Lazy Loading**: Uses lazy.nvim for efficient plugin management and loading
3. **LSP Integration**: Full Language Server Protocol support with Mason for tool management
4. **Modular Organization**: Configuration is organized into logical modules for maintainability

## Directory Structure

```
.
├── init.lua                 # Main entry point
├── lua/
│   ├── config/              # Core configuration modules
│   │   ├── lsp/             # LSP configurations
│   │   └── ...              # Other core configs
│   ├── plugins/             # Plugin specifications
│   │   ├── ai/              # AI-related plugins
│   │   ├── buffer/          # Buffer management
│   │   ├── completion/      # Completion engines
│   │   └── ...              # Other plugin categories
│   └── utils/               # Utility functions
├── lsp/                     # LSP server configurations
├── snippets/                # Code snippets
└── docs/                    # Documentation
```

## Core Configuration

### Entry Point: init.lua
The main configuration file that loads all modules in order:
1. Environment setup
2. Keymaps
3. Options
4. Autocommands
5. LSP bootstrap
6. Lazy plugin management

### Key Features

#### Buffer Management
- Uses Shift+H/Shift+L to navigate between buffers
- Smart buffer closing (quits if only one buffer remains)
- Buffer-centric workflow instead of tab-based navigation

#### Window Management
- Ctrl+Shift+H/J/K/L for window navigation
- Proper split handling with splitright/splitbelow

#### LSP Integration
- Mason for automatic tool installation
- Support for multiple languages (Go, Rust, Python, C/C++, Lua, etc.)
- Custom LSP configurations in the `lsp/` directory

## Plugin Management

### System: lazy.nvim
Plugins are organized in the `lua/plugins/` directory by category:
- `ai/` - AI coding assistants
- `buffer/` - Buffer management
- `completion/` - Autocompletion engines
- `cursor/` - Cursor movement and text objects
- `dap/` - Debug Adapter Protocol (DAP) for debugging
- `file/` - File browsing and searching
- `format/` - Code formatting
- `fuzzy_finder/` - Fuzzy finding (Telescope)
- `git/` - Git integration
- `lang/` - Language-specific plugins
- `lsp/` - LSP related plugins
- `mason/` - Mason for tool management
- `treesitter/` - Treesitter syntax highlighting
- `ui/` - User interface enhancements

## Language Support

### Supported Languages
- **Go**: gopls, golangci-lint, delve (debugging)
- **Rust**: rust-analyzer, codelldb (debugging)
- **Python**: pyright, ruff, debugpy (debugging)
- **C/C++**: clangd, codelldb (debugging)
- **Lua**: lua-language-server
- **Shell**: bash-language-server
- **JSON**: jsonls
- **YAML**: yamlls

### DAP
- Debug Adapter Protocol support for Go, Python, C/C++, Rust
- Integrated debugging UI with variable inspection
- Breakpoint management and step debugging
- Language-specific debugging configurations

### DAP Configuration
Debugging support is provided through the Debug Adapter Protocol (DAP) with language-specific adapters:
- **Go**: Delve debugger
- **Python**: debugpy
- **C/C++/Rust**: CodeLLDB

## Keymaps

### Navigation
- `Space` - Leader key
- `Shift+H`/`Shift+L` - Previous/next buffer
- `Ctrl+Shift+H/J/K/L` - Window navigation

### File Operations
- `Leader+q` - Close buffer or quit if last buffer
- `Leader+w` - Save current buffer
- `Leader+W` - Save all buffers
- `Leader+Q` - Force quit

### DAP (Debug Adapter Protocol)
- F5 - Continue execution
- F9 - Toggle breakpoint
- F10 - Step over
- F11 - Step into
- F12 - Step out

## Development Environment

### Mason Tools
Automatically installs and manages:
- LSP servers for all supported languages
- Linters and formatters (stylua, black, ruff, etc.)
- Debug adapters (delve, codelldb, debugpy)

### Custom Utilities
The `utils/` directory contains custom helper modules:
- `bind.lua` - Keymap DSL
- `mason.lua` - Tool and server management
- `dap.lua` - Debug adapter configuration
- `icons.lua` - Icon management

## Building and Running

### Setup Commands
1. Start Neovim: `nvim`
2. Plugins will be automatically installed on first run
3. LSP servers will be automatically installed via Mason

### Custom Commands
- `:LspInfo` - Check LSP health
- `:LspLog` - View LSP logs
- `:LspRestart [server]` - Restart specific LSP server

## Development Conventions

### Configuration Philosophy
- Modular organization with clear separation of concerns
- Buffer-centric workflow over tab-based navigation
- Lazy loading for performance
- Extensive use of Neovim's built-in features

### Keymap Conventions
- Leader key is Space
- Descriptive keymap descriptions for all mappings
- Consistent naming patterns for custom commands

### Plugin Organization
- Plugins organized by functionality rather than author
- README files explaining plugin categorization
- Clear separation between configuration and plugin specs

## Workflow Patterns

### File Management
- Buffers represent files, not tabs
- Smart buffer switching with minimal keypresses
- Automatic session management

### Code Editing
- LSP-powered completions and diagnostics
- Treesitter-based syntax highlighting
- Integrated formatting and linting

### Navigation
- Efficient buffer switching
- Window management without tabs
- Fuzzy finding for files and symbols

## Customization Points

### Adding New Languages
1. Add LSP server to `utils/mason.lua`
2. Add to enabled servers in `config/lsp/enable_list.lua`
3. Create configuration file in `lsp/` directory

### Adding New Plugins
1. Create plugin specification in appropriate category under `lua/plugins/`
2. Lazy will automatically load it

### Custom Keymaps
1. Add to `lua/config/keymaps.lua`
2. Use the `bind` utility for consistent keymap definitions

## Troubleshooting

### Common Issues
- If LSP servers aren't working, check `:LspInfo`
- If plugins aren't loading, check with `:Lazy`
- For performance issues, check startup time with `:StartupTime`

### Logs
- LSP logs: `:LspLog`
- General Neovim logs: Check `stdpath('log')`