{ pkgs
, config
, lib
, ...
}:
let
  cfg = config.local.nixvim;
  inherit (lib) mkOption mkIf types;
in
{
  options.local.nixvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    rust = mkOption {
      type = types.bool;
      default = false;
    };
    python = mkOption {
      type = types.bool;
      default = false;
    };
    javascript = mkOption {
      type = types.bool;
      default = false;
    };
    smartUndo = mkOption {
      type = types.bool;
      default = true;
    };
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
      colorscheme = null;
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
        undofile = true;
        undolevels = 10000;
      };
      # Smart Per-Repo Ephemeral Undo logic + Permanent fallback
      extraConfigLua = mkIf cfg.smartUndo ''
        local function setup_smart_undo()
          -- Try to find the root of the repo
          local dot_git = vim.fn.finddir(".git", ".;")
          
          if dot_git ~= "" then
            local repo_root = vim.fn.fnamemodify(dot_git, ":h")
            local marker = repo_root .. "/.undo"
            
            -- IF marker exists: use ephemeral local dir
            if vim.fn.filereadable(marker) == 1 or vim.fn.isdirectory(marker) == 1 then
              local undo_path = repo_root .. "/.undo_dir"
              if vim.fn.isdirectory(undo_path) == 0 then
                vim.fn.mkdir(undo_path, "p")
              end
              vim.opt.undodir = undo_path
              return
            end
          end

          -- FALLBACK: For non-git files or repos without .undo marker
          -- Use a permanent cache directory
          local permanent_path = vim.fn.expand("~/.cache/nvim/undo")
          if vim.fn.isdirectory(permanent_path) == 0 then
            vim.fn.mkdir(permanent_path, "p")
          end
          vim.opt.undodir = permanent_path
        end

        setup_smart_undo()
      '';

      keymaps = [
        {
          mode = "n";
          key = "gg=G";
          action = "<cmd>lua vim.lsp.buf.format()<CR>";
          options = {
            silent = true;
            desc = "format whole file";
          };
        }
        {
          mode = "n";
          key = "rp";
          action = "<cmd>split | term cargo run<CR>i";
          options.desc = "Cargo Run Project";
        }
        {
          mode = "n";
          key = "rb";
          action = "<cmd>split | term cargo build<CR>i";
          options.desc = "Cargo Build Project";
        }
      ];
      plugins = {
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
        lsp-signature-help.enable = true;

        treesitter = {
          enable = true;
          nixGrammars = true;
          settings.highlight.enable = true;
        };
        friendly-snippets.enable = true;
        luasnip.enable = true;
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
