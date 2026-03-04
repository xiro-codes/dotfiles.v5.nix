# nixvim

This module provides a comprehensive Nix configuration for Neovim, enabling easy management of plugins, settings, and keybindings. It allows you to declaratively configure your Neovim environment with Nix, ensuring reproducibility and consistency across different machines.

## Options

### `local.nixvim.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the nixvim configuration. When set to `true`, this option activates the Neovim configuration defined within the module.  This is the primary switch to turn on all nixvim related configurations.

### `local.nixvim.rust`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables Rust language support within Neovim.  This includes installing necessary plugins and configuring settings specifically tailored for Rust development.  Enabling this will likely pull in rust-tools.nvim, treesitter, and other related plugins through the `plugins.nix` file (though not explicitly shown in this file).

### `local.nixvim.smartUndo`

*   **Type:** `types.bool`
*   **Default:** `true`
*   **Description:** Enables persistent undo functionality with smart directory management. This creates persistent undo files that are stored in a project-specific directory, allowing you to undo changes even after closing and reopening files. Smart directory management organizes these undo files based on your project structure, preventing conflicts and keeping your undo history clean. This uses `undodir` setting to keep undo history persistent.  This option is set to true by default.

## Configuration Details

When `local.nixvim.enable` is set to `true`, the following configuration is applied:

*   **`home.packages`:**
    *   Installs global command-line tools: `nixpkgs-fmt`, `neovide`, and `lazygit`.  `nixpkgs-fmt` is useful for formatting Nix code, `neovide` provides a GUI for Neovim, and `lazygit` simplifies Git operations.

*   **`programs.nixvim`:** This section contains the main Neovim configuration.
    *   `enable = true;`: Activates the Neovim configuration managed by this module.
    *   `defaultEditor = true;`: Sets Neovim as the default editor for the system.
    *   `globals`, `opts`, `extraConfigLua`: Inherits these settings from `./options.nix`.  This file likely contains global Neovim options, custom settings, and extra Lua configurations.
    *   `keymaps`: Inherits keybindings from `./keymaps.nix`. This allows declarative management of keyboard shortcuts.
    *   `files."ftplugin/gdscript.lua"`: Configures file-type-specific settings for GDScript files:
        *   `expandtab = false;`: Disables the use of spaces instead of tabs.
        *   `shiftwidth = 4;`: Sets the number of spaces used for indentation to 4.
        *   `tabstop = 4;`: Sets the visual width of a tab to 4 spaces.
    *   `plugins`: Merges the base plugin configuration with a custom dashboard plugin:
        *   `alpha = dashboard;`: Adds the dashboard plugin configuration from `./dashboard.nix`, likely using the alpha.nvim plugin for the dashboard.
    *   `extraPackages`: Installs extra command-line tools available within Neovim:
        *   `ripgrep`: A fast and efficient search tool.
        *   `fd`: A simple and user-friendly alternative to `find`.
        *   `gcc`: The GNU Compiler Collection, necessary for building some treesitter parsers from source.

This module heavily relies on external Nix files (`./options.nix`, `./dashboard.nix`, `./plugins.nix`, `./keymaps.nix`) for organizing configurations, plugins, and keybindings.  Consider examining the contents of these files for a complete understanding of the Neovim configuration.
