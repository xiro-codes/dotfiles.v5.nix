{ config, lib, pkgs, ... }:

let
  cfg = config.local.fish;
  isDefaultShell = (config.osConfig.users.users.${config.home.username}.shell or null) == pkgs.fish;
in
{
  options.local.fish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = isDefaultShell;
      description = "Enable fish config if it is the system shell.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.eza.enable = true;
    programs.zoxide.enable = true;

    home.packages = with pkgs; [
      trash-cli
      fastfetch
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting ""
        zoxide init fish | source
        set -g fish_key_bindings fish_vi_key_bindings
        # cat $HOME/.local/state/caelestia/sequences.txt 2>/dev/null 
        fastfetch
      '';
      shellAbbrs = {
        cd = "z";
        find = "zi";
        ls = "eza --icons always";
        lsa = "eza --icons always --all";
        lsl = "eza --icons always -al";
        du = "dust";
        df = "duf";
        rm = "trash";
        ranger = "yazi";
        fm = "yazi";
      };
    };
  };
}
