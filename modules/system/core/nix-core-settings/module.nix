{
  pkgs,
  lib,
  config,
  flake-inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.local.nix-core-settings;
in
{
  options.local.nix-core-settings = {
    enable = mkEnableOption "Basic system and Nix settings";
  };

  config = mkIf cfg.enable {
    system.nixos.label =
      let
        rev = flake-inputs.self.sourceInfo.shortRev or "dirty";
        count =
          if flake-inputs.self.sourceInfo ? revCount then
            toString flake-inputs.self.sourceInfo.revCount
          else
            "unknown";
      in
      lib.mkDefault "${config.system.nixos.release}-${config.system.nixos.versionSuffix}-commits-${count}";

    # Nix configuration
    determinate.enable = true;
    nix.settings = {
      accept-flake-config = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Basic system packages
    environment.systemPackages = with pkgs; [
      neovim
    ];

    # Ignore ISO 9660 recovery partitions from automount
    services.udev.extraRules = ''
      ENV{ID_FS_UUID}=="1980-01-01-00-00-00-00", ENV{UDISKS_IGNORE}="1"
    '';
  };
}
