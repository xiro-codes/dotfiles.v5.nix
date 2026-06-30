{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe makeBinPath;
in
pkgs.stdenv.mkDerivation rec {
  pname = "shoko-server";
  version = "5.3.3";

  src = pkgs.fetchzip {
    url = "https://github.com/ShokoAnime/ShokoServer/releases/download/v${version}/Shoko.CLI_Framework_any-x64.zip";
    hash = "sha256-CJQK1m1qCAx9Iz7sxm+A4OQdXMUOTAzAcIMaKTRC6Fk=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
    pkgs.fontconfig
    pkgs.icu
    pkgs.openssl
    pkgs.sqlite
  ];

  installPhase = ''
    mkdir -p $out/lib/shoko-server
    cp -r publish/* $out/lib/shoko-server/
    
    mkdir -p $out/bin
    
    makeWrapper ${getExe pkgs.dotnetCorePackages.sdk_8_0} $out/bin/Shoko.CLI \
      --add-flags "$out/lib/shoko-server/Shoko.CLI.dll" \
      --set DOTNET_ROOT "${pkgs.dotnetCorePackages.sdk_8_0}" \
      --set LD_LIBRARY_PATH "${makeBinPath buildInputs}:$out/lib/shoko-server"
  '';

  meta = with lib; {
    description = "Shoko Server is an anime cataloging program designed to automate the cataloging of your collection.";
    homepage = "https://shokoanime.com/";
    license = licenses.gpl3Only;
    maintainers = [ "tod" ];
    platforms = [ "x86_64-linux" ];
  };
}
