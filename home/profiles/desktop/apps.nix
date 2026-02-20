{ pkgs, inputs, ... }:
{
  local = {
    kitty.enable = true;
    nixvim.enable = true;
    yazi.enable = true;
    superfile.enable = true;
    mpd.enable = true;
    caelestia.enable = true;
  };

  home.packages = with pkgs; [
    # Desktop applications
    discord
    protonvpn-gui
    graphite
    unzip
    p7zip
  ] ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
    tgpt-auth
  ]);
}
