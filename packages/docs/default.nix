{ pkgs, inputs, ... }:

let
  docs-generated = inputs.self.packages.${pkgs.system}.docs-generated;
in
pkgs.stdenv.mkDerivation {
  name = "docs";
  src = docs-generated;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';
  passthru.updateScript = pkgs.writeShellScriptBin "update-docs" ''
    set -euo pipefail
    echo "Updating docs..."
    cp -f ${docs-generated}/README.md ./docs/modules.md
    cp -f ${docs-generated}/system-modules.md ./docs/system-modules.md
    cp -f ${docs-generated}/home-modules.md ./docs/home-modules.md
    echo "Docs updated!"
  '';
}
