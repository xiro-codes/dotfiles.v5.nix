{ config, lib, ... }:

let
  cfg = config.local.registry;
in
{
  options.local.registry = {
    enable = lib.mkEnableOption "Flake registry for dotfiles";
  };

  config = lib.mkIf cfg.enable {
    # Make dotfiles flake available as 'dotfiles' registry entry
    nix.registry.dotfiles = {
      from = {
        type = "indirect";
        id = "dotfiles";
      };
      to = {
        type = "path";
        path = "/etc/nixos";
      };
    };

    # Also make it available via NIX_PATH for classic nix commands
    nix.nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
      "dotfiles=/etc/nixos"
    ];
  };
}
