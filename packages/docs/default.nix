{ pkgs, ... }:

pkgs.homepage-dashboard.overrideAttrs (oldAttrs: {
  postInstall = ''
    mkdir -p $out/www/icons
    cp ${./book.svg} $out/www/icons/
  '';
})
