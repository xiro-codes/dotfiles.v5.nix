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
  avante = {
    enable = true;
    settings = {
      provider = "gemini";
      auto_suggestions_provider = "gemini";
      gemini = {
        model = "gemini-2.0-flash";
        max_token = 4096; 
        temperature = 0;
      };
      behaviour = {
        auto_suggestions = false; # Set to true for Copilot-style ghost text
        auto_set_highlight_group = true;
        auto_set_keymaps = true;
        auto_apply_diff_after_generation = false;
        support_paste_from_clipboard = true;
      };
      mappings = {
        ask = "<leader>aa";
        edit = "<leader>ae";
        refresh = "<leader>ar";
        focus = "<leader>af";
        toggle = {
          default = "<leader>at";
          debug = "<leader>ad";
          hint = "<leader>ah";
        };
        diff = {
          ours = "co";
          theirs = "ct";
          none = "c0";
          both = "cb";
          next = "]x";
          prev = "[x";
        };
        suggestion = {
          accept = "<M-l>";
          next = "<M-]>";
          prev = "<M-[>";
          dismiss = "<C-]> ";
        };
      };
    };
  };
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
