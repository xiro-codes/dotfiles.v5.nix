{ pkgs, config, lib, ... }:
let
  cfg = config.local.nixvim;
in
{
  blink-cmp = {
    enable = true;
    settings = {
      appearance.nerd_font_variant = "mono";
      completion.ghost_text.enabled = true;
      sources.default = [ "lsp" "path" "snippets" "buffer" ];
      keymap.preset = "enter";
    };
  };

  lazygit.enable = true;
  web-devicons.enable = true;
  lualine.enable = true;
  telescope.enable = true;
  which-key.enable = true;

  neo-tree.enable = true;

  lsp = {
    enable = true;
    servers = {
      nixd = {
        enable = true;
        settings = {
          nixpkgs.expr = "import <nixpkgs> { }";
          options = {
            nixos.expr = ''
              let flake = builtins.getFlake ("''${builtins.toString ./.}");
              in flake.nixosConfigurations.Ruby.options // flake.nixosConfigurations.Sapphire.options
            '';
            home-manager.expr = ''
              let flake = builtins.getFlake ("''${builtins.toString ./.}");
              in flake.homeConfigurations."tod@Ruby".options // flake.homeConfigurations."tod@Sapphire".options
            '';
          };
        };
      };
      rust_analyzer.enable = cfg.rust;
    };
  };

  treesitter.enable = true;
  conform-nvim.enable = true;
}
