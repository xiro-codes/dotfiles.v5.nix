{ pkgs, ... }:
pkgs.writeShellScriptBin "setup-ddns-config" ''
  TOKEN_FILE=$1
  ZONE_FILE=$2
  CFG_FILE=$3

  mkdir -p /etc/ddns-updater
  TOKEN=$(cat "$TOKEN_FILE")
  ZONE=$(cat "$ZONE_FILE")
  ${pkgs.jq}/bin/jq --arg token "$TOKEN" --arg zone "$ZONE" \
    '.settings |= map(.token = $token | .zone_identifier = $zone)' \
    < "$CFG_FILE" > /etc/ddns-updater/config.json
  chmod 777 /etc/ddns-updater/config.json
''
