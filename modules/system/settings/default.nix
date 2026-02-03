{ pkgs, lib, config, ... }:
let
  cfg = config.local.settings;
in
{
  options.local.settings = {
    enable = lib.mkEnableOption "Basic system and Nix settings";
  };
  
  config = lib.mkIf cfg.enable {
    # Nix configuration
    nix.settings = {
      accept-flake-config = true;
      experimental-features = [ "nix-command" "flakes" ];
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
