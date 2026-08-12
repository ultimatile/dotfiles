# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a LazyVim-based Neovim configuration. Layout, plugin-spec conventions,
and enabled extras are all readable from the tree itself (`lua/config/`,
`lua/plugins/`, `lazyvim.json`); what follows is only what the code cannot tell
you.

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