# Nixvim (Neovim)

The `nixvim` module configures Neovim using Nix, providing a reproducible development environment.

## Configuration

```nix
local.nixvim = {
  enable = true;
  rust = true;       # Enable Rust LSP/Tools
  smartUndo = true;  # Persistent undo history
};
```

## Included Tools

- **LSP**: `rust-analyzer` (if enabled), others via plugins.
- **Formatting**: `nixpkgs-fmt`
- **UI**: `neovide` support
- **Git**: `lazygit` integration

## Internal Structure

The configuration is split into several imports:
- `options.nix`: Basic vim options
- `keymaps.nix`: Keybindings
- `plugins.nix`: Plugin configuration
- `dashboard.nix`: Startup dashboard
