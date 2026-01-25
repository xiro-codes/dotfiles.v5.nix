{pkgs, config, lib, ... }: 
let 
cfg = config.local.nixvim;
inherit (lib) mkOption mkIf types;
in {
  options.local.nixvim = {
    enable = mkOption {type = types.bool; default = false; };
    rust = mkOption { type = types.bool; default = false; };
    python = mkOption { type = types.bool; default = false; };
    javascript = mkOption { type = types.bool; default = false; };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-fmt
        rustfmt
        black
    ];
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      globals.mapleader = ";";
      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        smartindent = true;
        cursorline = true;
        scrolloff = 8;
        termguicolors = true;
      };
      colorschemes.catppuccin.enable = true;
      keymaps = [
      { mode = "n"; key = "gg=G"; action = "<cmd>lua vim.lsp.buf.format()<CR>"; options = { silent = true; desc = "format whole file";};}
      ]; 
      plugins = {
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              nix = ["nixpkgs_fmt"];
              rust = ["rustfmt"];
              python = ["black"];
              "_" = ["trim_whitespace"];
            };
            format_on_save = {
              lspFallback = true;
              timeoutMs = 500;
            };
          };
        };
        lualine.enable = true;
        neo-tree.enable = true;
        telescope.enable = true;
        which-key.enable = true;
        web-devicons.enable = true;
        treesitter = {
          enable = true;
          nixGrammars = true;
          settings.highlight.enable = true;
        };
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            rust_analyzer = {
              enable = true;
              installRustc = false;
              installCargo = false;
            };
          };
        };
        cmp = {
          enable = true;
          settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer";}
          ];
        };

      };


      extraPackages = with pkgs; [
        ripgrep
          fd
          gcc # For treesitter builds
      ];
    };
  };
}
