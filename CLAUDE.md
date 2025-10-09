# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a LazyVim-based Neovim configuration optimized for PHP/Laravel development. The configuration follows the standard LazyVim structure:

- **Entry Point**: `init.lua` bootstraps the lazy.nvim plugin manager
- **Core Configuration**: `lua/config/` contains main configuration files
  - `lazy.lua`: Plugin manager setup and LazyVim integration
  - `options.lua`: Neovim options and global variables
  - `keymaps.lua`: Custom key mappings with smart Laravel/Inertia navigation
  - `autocmds.lua`: Auto-commands for editor behavior
- **Plugin Configurations**: `lua/plugins/` contains plugin-specific configurations
  - `php.lua`: PHP development setup with Intelephense LSP and Laravel.nvim
  - `example.lua`: Template for additional plugin configurations

## Key Features

### PHP/Laravel Development
- **LSP**: Configured to use Intelephense as the PHP language server (set in `options.lua`)
- **Laravel Integration**: Uses `laravel.nvim` plugin with key bindings:
  - `<leader>la`: Laravel Artisan commands
  - `<leader>lc`: Composer commands  
  - `<leader>lr`: Laravel routes browser
  - `<leader>lm`: Laravel make commands
- **Smart Navigation**: Custom `gd` (go to definition) that handles:
  - Standard LSP go-to-definition
  - Inertia.js page navigation (searches for .tsx, .vue, .jsx files)
  - Blade view navigation with dot notation support

### LazyVim Extras
- GitHub Copilot integration (`lazyvim.plugins.extras.ai.copilot`)
- Alpha dashboard (`lazyvim.plugins.extras.ui.alpha`)

## Development Commands

### Code Formatting
- **Lua formatting**: Uses stylua with configuration in `stylua.toml`
  - Indent: 2 spaces
  - Column width: 120 characters
  - Command: `stylua .` (if stylua is installed)

### Neovim Configuration Management
- **Plugin Updates**: Use `:Lazy update` to update all plugins
- **Plugin Installation**: Plugins are auto-installed on startup via lazy.nvim
- **Health Check**: Run `:checkhealth` to verify configuration

### Laravel Development Workflow
Within Neovim:
1. Use `<leader>la` to run Artisan commands
2. Use `<leader>lm` to generate Laravel files (models, controllers, etc.)
3. Use `gd` on Inertia page names or Blade view names for smart navigation
4. Use `<leader>lr` to browse Laravel routes

## File Structure
```
├── init.lua                 # Entry point
├── lazy-lock.json          # Plugin version lockfile  
├── lazyvim.json           # LazyVim extras configuration
├── stylua.toml            # Lua formatting configuration
├── .neoconf.json          # Neovim configuration metadata
└── lua/
    ├── config/
    │   ├── lazy.lua       # Plugin manager setup
    │   ├── options.lua    # Neovim options
    │   ├── keymaps.lua    # Custom key mappings
    │   └── autocmds.lua   # Auto-commands
    └── plugins/
        ├── php.lua        # PHP/Laravel configuration
        └── example.lua    # Plugin template
```

## Important Notes
- This configuration inherits all LazyVim defaults and keymaps
- PHP LSP is explicitly set to use Intelephense
- Laravel Sail support is enabled for containerized development
- The smart navigation function prioritizes LSP definitions but falls back to file-based navigation for Laravel-specific patterns