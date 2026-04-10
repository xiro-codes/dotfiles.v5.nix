```markdown
# nixvim

This Nix module provides a comprehensive configuration for Neovim, enabling various features, language support, and plugins. It leverages the `nixvim` Nix package for a declarative and reproducible Neovim setup. This module allows you to easily manage your Neovim configuration, plugins, and settings through Nix.

## Options

This module provides the following options:

### `local.nixvim.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**  Enables the entire `nixvim` configuration. When set to `true`, the module will configure Neovim with the settings defined in this module.  Disabling it will effectively skip all `nixvim` related configuration.

### `local.nixvim.rust`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables Rust language support within Neovim.  This option is intended to control parts of the Nixvim config related to rust development such as lsp, formatters and linters. The details of how rust support is enabled are configured within the other imported files.

### `local.nixvim.smartUndo`

*   **Type:** `types.bool`
*   **Default:** `true`
*   **Description:** Enables persistent undo functionality with smart directory management.  This will typically configure Neovim to store undo history in a dedicated directory, allowing you to undo changes even after closing and reopening the file. It also aims to manage this undo directory more effectively than the default behavior.

## Configuration

When `local.nixvim.enable` is set to `true`, the following configuration is applied:

*   **Packages:** Installs the following packages using `home.packages`:
    *   `nixpkgs-fmt`: For formatting Nix code.
    *   `neovide`: A modern, GPU-accelerated Neovim GUI.
    *   `lazygit`: A TUI client for Git.

*   **`programs.nixvim`:** Configures the `nixvim` package itself:
    *   `enable = true`:  Enables the `nixvim` module.
    *   `defaultEditor = true`: Makes Neovim the default editor.
    *   `globals`, `opts`, `extraConfigLua`:  Options imported from `./options.nix`, allowing you to set global variables, editor options, and execute custom Lua code.
    *   `keymaps`: Keymaps imported from `./keymaps.nix`, allowing you to define custom keybindings.
    *   `files."ftplugin/gdscript.lua"`: Configures filetype-specific settings for GDScript files, setting `expandtab`, `shiftwidth`, and `tabstop` to 4.
    *   `plugins`:  Combines plugins imported from `./plugins.nix` with a dashboard configuration imported from `./dashboard.nix`.  The `plugins.alpha` plugin is replaced with the contents of the dashboard config.
    *   `extraPackages`: Adds the following packages to the Neovim environment:
        *   `ripgrep`: A fast search tool.
        *   `fd`: A simple, fast and user-friendly alternative to `find`.
        *   `gcc`: For building treesitter grammars.
```
