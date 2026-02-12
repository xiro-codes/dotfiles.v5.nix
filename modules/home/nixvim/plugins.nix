{ pkgs, config, lib, ... }:
let
  cfg = config.local.nixvim;
in
{
  blink-cmp = {
    enable = true;
    settings = {
      appearance = {
        use_nvim_cmp_as_default = true;
        nerd_font_variant = "mono";
      };
      completion = {
        ghost_text.enabled = true;
        documentation.auto_show = true;
        menu.draw.columns = [
          [ "kind_icon" ]
          [ "label" "label_description" ]
          [ "source_name" ]
        ];
      };
      sources = {
        default = [ "lsp" "path" "snippets" "buffer" ];
        providers = {
          lsp.score_offset = 100;
          buffer.score_offset = 5;
        };
      };
      keymap = {
        preset = "enter";
        "<Tab>" = [ "select_next" "fallback" ];
        "<S-Tab>" = [ "select_prev" "fallback" ];
      };
    };
  };

  lazygit.enable = true;
  web-devicons.enable = true;
  lualine.enable = true;
  telescope.enable = true;
  which-key.enable = true;
  toggleterm = {
    enable = true;
    settings = {
      open_mapping = "[[<C-t>]]";
      derection = "float";
      float_opts = {
        border = "curved";
        winblend = 3;
      };
      start_in_insert = true;
      terminal_mappings = true;
      insert_mappings = true;
    };
  };

  neo-tree.enable = true;
  lsp-signature-help.enable = true;
  friendly-snippets.enable = false;
  luasnip.enable = false;

  lsp = {
    enable = true;
    servers = {
      # nixls.enable = true;
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
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
    };
  };
  cmp = {
    enable = true;
    settings.sources = [
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
    ];
  };
  treesitter = {
    enable = true;
    nixGrammars = true;
    settings.highlight.enable = true;
  };
  conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        nix = [ "nixpkgs_fmt" ];
        rust = [ "rustfmt" ];
        "_" = [ "trim_whitespace" ];
      };
      format_on_save = {
        lspFallback = true;
        timeoutMs = 500;
      };
    };
  };
}
