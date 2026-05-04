{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "upload-to-onix";
  text = ''
    set -eu
    if [ -n "''${OUT_PATHS:-}" ]; then
      echo "Uploading to Onix cache: $OUT_PATHS"
      # shellcheck disable=SC2086
      ${pkgs.nix}/bin/nix copy --to http://192.168.1.65:5000 $OUT_PATHS || true
    fi
  '';
}
