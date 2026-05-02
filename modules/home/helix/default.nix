{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.local.helix;
  inherit (lib) mkOption mkIf types;
in
{
  options.local.helix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable helix configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lazygit
      nixfmt-rfc-style
      ripgrep
      fd
      nixd
      jq
    ];

    programs.helix = {
      enable = true;
      defaultEditor = false;
      settings = {
        theme = "default";
        editor = {
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          idle-timeout = 50;
          true-color = false; # termguicolors = false in nixvim
          
          indent-guides = {
            render = true;
            character = "▏";
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          statusline = {
            left = ["mode" "spinner" "file-name"];
            center = [];
            right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };
        };

        keys.normal = {
          space.g.g = ":sh lazygit"; # like <leader>gg
          C-n = "file_picker"; # like <C-n> for neotree
        };
      };

      languages = {
        language-server.nixd = {
          command = "nixd";
        };
        language-server.rust-analyzer = {
          command = "rust-analyzer";
        };
        language-server.gdscript = {
          command = "nc";
          args = [ "127.0.0.1" "6005" ];
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = { command = "nixfmt"; };
            language-servers = [ "nixd" ];
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = [ "rust-analyzer" ];
          }
          {
            name = "json";
            auto-format = true;
            formatter = { command = "jq"; };
          }
          {
            name = "gdscript";
            language-servers = [ "gdscript" ];
            indent = { tab-width = 4; unit = "\t"; };
          }
        ];
      };
    };
  };
}
