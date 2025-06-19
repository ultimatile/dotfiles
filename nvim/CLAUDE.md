# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Architecture

This is a **LazyVim-based Neovim configuration** with extensive customizations. The codebase follows LazyVim's modular plugin architecture:

- **`init.lua`**: Entry point that loads the lazy.nvim plugin manager
- **`lua/config/`**: Core LazyVim configuration overrides
  - `lazy.lua`: Plugin manager setup and LazyVim base configuration
  - `options.lua`: Vim options and global settings
  - `keymaps.lua`: Custom key mappings with utility functions
  - `autocmds.lua` & `usercmds.lua`: Autocommands and user commands
- **`lua/plugins/`**: Individual plugin configurations that extend/override LazyVim defaults
- **`lazyvim.json`**: LazyVim extras configuration defining enabled language support and features

## Plugin Configuration Patterns

### Plugin File Structure
All plugin files return Lua tables following LazyVim conventions:
```lua
return {
  "plugin/name",
  opts = { ... },  -- Simple configuration
  -- or
  opts = function() return { ... } end,  -- Complex/conditional configuration
}
```

### Key Configuration Approaches
- **Minimal Overrides**: Most plugins only override necessary settings, preserving LazyVim defaults
- **Functional Composition**: Complex behaviors built by composing simple functions (see `copilot.lua`)
- **Filetype-Specific**: Configurations adapt based on file types (e.g., Julia-specific settings in `blink.lua`)
- **LazyVim Integration**: Heavy use of `LazyVim.cmp.actions` and other LazyVim utilities

## Development Commands

### Code Formatting
```bash
# Format Lua code (uses stylua.toml config)
stylua .
```

### Configuration Management
```bash
# Update plugin lockfile
:Lazy sync

# Check plugin status
:Lazy

# Update LazyVim
:LazyVim
```

## Key Customizations

### Keyboard Layout
This configuration uses a **custom JKLS movement scheme**:
- `j/k/l/;` → left/up/down/right (replaces hjkl)
- `h` → repeat last f/F/t/T search
- Custom Q-prefix commands for session management

### Unique Features
- **Non-destructive delete**: `d/c/x` operations don't yank to clipboard
- **Original delete**: `<leader>D` performs yanking delete operations  
- **Line manipulation**: Advanced line duplication and movement with `<C-P>` and `<M-Up/Down>`
- **Buffer navigation**: `<Tab>` for window switching, `<S-Tab>` for buffer cycling
- **AI Integration**: Copilot with custom completion behavior and chat integration

### AI Features
- Copilot enabled with `vim.g.ai_cmp = false` (tab-based acceptance)
- Blink completion engine with copilot integration
- Custom word-level suggestion acceptance

## Configuration Philosophy

- **LazyVim-First**: Extend rather than replace LazyVim functionality
- **Minimal Changes**: Only override what's necessary for personal workflow
- **Modular Design**: Each plugin gets its own configuration file
- **Integration Focus**: Plugins configured to work seamlessly together

## Language Support

Enabled LazyVim extras include: Python, Rust, C/C++, TeX/LaTeX, Markdown, JSON, YAML, TOML, Nushell, and Git integration.