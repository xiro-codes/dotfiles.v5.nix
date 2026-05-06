{
  inputs,
  pkgs,
  inputs-nix,
  ...
}:
{
  environment.systemPackages = [
    inputs-nix.inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.kdeconnect.enable = true;
}
