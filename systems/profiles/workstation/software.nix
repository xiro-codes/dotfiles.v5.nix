{ inputs, pkgs, ... }:
let
  zen-browser-fixed = (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default).overrideAttrs (oldAttrs: {
    buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.libpulseaudio ];
    preFixup = (oldAttrs.preFixup or "") + ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libpulseaudio ]}"
      )
    '';
  });
in
{
  environment.systemPackages = [
    zen-browser-fixed
  ];
  programs.kdeconnect.enable = true;
}
