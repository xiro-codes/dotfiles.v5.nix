{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.starship;
in
{
  options.local.starship = {
    enable = mkEnableOption "Starship prompt configuration";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        format = ''
          (white)$username@$hostname $directory($git_branch)$nix_shell$rust$python$shlvl$character
        '';

        # 2. Replicate the [I] and user@host style
        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "white";
        };

        hostname = {
          ssh_only = false;
          format = "[$hostname]($style) ";
          style = "white";
        };

        directory = {
          style = "blue";
          truncation_length = 3;
          fish_style_pwd_dir_length = 1; # Replicates ~/P/style
        };

        git_branch = {
          symbol = ""; # Remove the default icon if you want it exactly like std fish
          format = "([$branch]($style)) ";
          style = "white";
        };

        # 3. Additions for Nix, Rust, and Python
        nix_shell = {
          symbol = "❄️";
          format = "[$symbol]($style) ";
          style = "bold blue";
        };

        rust = {
          symbol = "🦀";
          format = "[$symbol]($style) ";
          style = "bold red";
        };

        python = {
          symbol = "🐍";
          format = "[$symbol]($style) ";
          style = "yellow";
        };

        shlvl = {
          disabled = false;
          symbol = "🐚";
          threshold = 3;
          format = "[$symbol$shlvl]($style) ";
        };

        character = {
          success_symbol = "[>](bold white)";
          error_symbol = "[>](bold red)";
        };
      };
    };
  };
}
