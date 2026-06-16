{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
in
pkgs.writeShellApplication {
  name = "setup-ddns-config";
  text = ''
    TOKEN_FILE=$1
    ZONE_FILE=$2
    CFG_FILE=$3

    mkdir -p /etc/ddns-updater
    TOKEN=$(cat "$TOKEN_FILE")
    ZONE=$(cat "$ZONE_FILE")
    ${getExe pkgs.jq} --arg token "$TOKEN" --arg zone "$ZONE" \
      '.settings |= map(.token = $token | .zone_identifier = $zone)' \
      < "$CFG_FILE" > /etc/ddns-updater/config.json
    chmod 777 /etc/ddns-updater/config.json
  '';
}
