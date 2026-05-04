{ pkgs, ... }:
let
  gogCmd = "${pkgs.lgogdownloader}/bin/lgogdownloader";
in
pkgs.writeShellApplication {
  name = "gog-sync-script";
  text = ''
    DIR=$1
    PLATFORMS=$2
    EXTRA_ARGS=''${*:3}

    # shellcheck disable=SC2086
    ${gogCmd} \
      --directory "$DIR" \
      --platform "$PLATFORMS" \
      $EXTRA_ARGS
  '';
}
