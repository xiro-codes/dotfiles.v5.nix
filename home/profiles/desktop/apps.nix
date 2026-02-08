{ pkgs, inputs, ... }:
{
  local = {
    kitty.enable = true;
    nixvim.enable = true;
    ranger.enable = true;
    mpd.enable = true;
    caelestia.enable = true;
  };

  home.packages = with pkgs; [
    # Desktop applications
    discord
    protonvpn-gui
  ] ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
  ]);
}
