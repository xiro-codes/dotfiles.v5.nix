{ config, lib, pkgs, osConfig ? { }, ... }:
let
  isDefaultShell = (osConfig.users.users.${config.home.username}.shell or null) == pkgs.fish;
in
{
  options.local.fish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = isDefaultShell;
      description = "Enable fish config if it is the system shell.";
    };
  };
  config = lib.mkIf config.local.fish.enable {
    programs.eza.enable = true;
    programs.zoxide.enable = true;


    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        				set -g fish_greeting ""
        				zoxide init fish | source
                cat $HOME/.local/state/caelestia/sequences.txt 2>/dev/null 
        			'';
      shellAbbrs = {
        ls = "eza --icons always";
        cd = "z";
        lsa = "eza --icons always --all";
        lsl = "eza --icons always -al";
        du = "dust";
        df = "duf";
        sudo = "doas";
        cat = "bat";
        grep = "rg";
        find = "fd";
        top = "btm";
        ps = "procs";
        man = "tldr";
        ping = "gping";
        dig = "dog";

      };
    };
  };
}
