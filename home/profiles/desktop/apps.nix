{ pkgs, inputs, ... }:
{
  local = {
    kitty.enable = true;
    nixvim.enable = true;
    yazi.enable = true;
    superfile.enable = true;
    mpd.enable = true;
    caelestia-shell.enable = true;
    kdeconnect.enable = true;
  };

  home.packages = with pkgs; [
    # Desktop applications
    discord
    proton-vpn
    proton-vpn-cli
    unzip
    p7zip

  ] ++ (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
    tgpt-auth
  ]);
}
