{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.kdeconnect.enable = true;
}
