{ pkgs, config, lib, ... }:
let
  cfg = config.local.nixvim;
  inherit (lib) mkOption mkIf types;
in
{
  options.local.nixvim = {
    enable = mkOption { type = types.bool; default = false; };
    rust = mkOption { type = types.bool; default = false; };
    python = mkOption { type = types.bool; default = false; };
    javascript = mkOption { type = types.bool; default = false; };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-fmt
      rustfmt
      black
      neovide
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
      colorschemes.base16 = {
        enable = true;
        setUpDefault = true;
      };
      # opts.guifont = "Cascadia Code:h13";
      extraConfigLua = ''
        -- Block the window manager from closing via Neovim internal calls
        vim.api.nvim_create_autocmd("QuitPre", {
          callback = function(data)
            print("Terminal Mode Active: Use System Keybind to Exit")
            vim.cmd("stopinstall") -- Prevents the quit process
          end,
        })
      '';

      keymaps = [
        { mode = "n"; key = "gg=G"; action = "<cmd>lua vim.lsp.buf.format()<CR>"; options = { silent = true; desc = "format whole file"; }; }
        { mode = "n"; key = ":q"; action = "<cmd>echo 'User your WM keybind to close Neovide!'<CR>"; }
        { mode = "n"; key = ":qa"; action = "<cmd>echo 'User your WM keybind to close Neovide!'<CR>"; }
        { mode = "n"; key = ":qa"; action = "<cmd>echo 'User your WM keybind to close Neovide!'<CR>"; }
        { mode = "n"; key = "rp"; action = "<cmd>split | term cargo run<CR>i"; options.desc = "Cargo Run Project"; }
        { mode = "n"; key = "rb"; action = "<cmd>split | term cargo build<CR>i"; options.desc = "Cargo Build Project"; }
      ];
      plugins = {
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
        neovide = {
          enable = true;
          settings = {
            confirm_quit = true;
            cursor_animation_length = 0.15;
            font = "Cascadia Code:h13";
            cursor_vfx_mode = "railgun";
            cursor_vfx_particle_speed = 10.0;
            refresh_rate = 75;
            rember_window_size = true;
            maximized = false;
          };
        };
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              nix = [ "nixpkgs_fmt" ];
              rust = [ "rustfmt" ];
              python = [ "black" ];
              "_" = [ "trim_whitespace" ];
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
            { name = "buffer"; }
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
