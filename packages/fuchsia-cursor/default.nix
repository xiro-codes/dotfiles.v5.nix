{
  pkgs,
  lib,
  fetchzip,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "fuchsia";
  version = "2.0.1";
  src = fetchzip {
    url = "https://github.com/ful1e5/fuchsia-cursor/releases/download/v${version}/Fuchsia.tar.xz";
    sha256 = "sha256-TuhU8UFo0hbVShqsWy9rTKnMV8/WHqsxmpqWg1d9f84=";
  };
  installPhase = ''
    mkdir -p $out/share/icons/${pname}
    cp -a $src/* $out/share/icons/${pname}
  '';
}
