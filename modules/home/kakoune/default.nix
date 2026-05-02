{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.local.kakoune;
  inherit (lib) mkOption mkIf types;
in
{
  options.local.kakoune = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable kakoune configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lazygit
      kakoune-lsp
      nixd
      nixfmt-rfc-style
      ripgrep
      fd
      jq
    ];

    programs.kakoune = {
      enable = true;
      config = {
        numberLines = {
          enable = true;
          highlightCursor = true;
          relative = true;
        };
        tabStop = 2;
        indentWidth = 2;
        wrapLines = {
          enable = true;
          word = true;
          marker = "⏎";
        };
        ui = {
          enableMouse = true;
        };
        hooks = [
          {
            name = "WinSetOption";
            option = "filetype=(nix|rust|gdscript)";
            commands = "lsp-enable-window";
          }
          {
            name = "WinSetOption";
            option = "filetype=gdscript";
            commands = ''
              set-option window tabstop 4
              set-option window indentwidth 4
            '';
          }
        ];
        keyMappings = [
          {
            mode = "normal";
            key = "<c-n>";
            effect = ": invoke file picker here<ret>"; # Depends on connect/find plugin, placeholder
          }
        ];
      };
      extraConfig = ''
        eval %sh{kak-lsp --kakoune -s $kak_session}
        
        map global user g ': terminal lazygit<ret>' -docstring 'Open LazyGit'
        
        # Format on save using lsp
        hook global BufWritePre .* lsp-formatting-sync
      '';
      plugins = with pkgs.kakounePlugins; [
        kak-lsp
      ];
    };
    
    xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
      [language_server.nixd]
      filetypes = ["nix"]
      roots = ["flake.nix", "default.nix"]
      command = "nixd"

      [language_server.rust-analyzer]
      filetypes = ["rust"]
      roots = ["Cargo.toml"]
      command = "rust-analyzer"

      [language_server.gdscript]
      filetypes = ["gdscript"]
      roots = ["project.godot"]
      command = "nc"
      args = ["127.0.0.1", "6005"]
    '';
  };
}
