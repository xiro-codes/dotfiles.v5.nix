{
  lib,
  writeShellApplication,
  systemd,
  nix,
  coreutils,
}:

writeShellApplication {
  name = "harmonia-upload-hook";
  runtimeInputs = [
    systemd
    nix
    coreutils
  ];
  text = ''
    set -eu
    if [ -n "''${OUT_PATHS:-}" ]; then
      if [ ! -f /etc/harmonia-upload-host.conf ]; then
        echo "Error: /etc/harmonia-upload-host.conf not found." >&2
        exit 1
      fi
      
      UPLOAD_HOST=$(cat /etc/harmonia-upload-host.conf)
      
      # shellcheck disable=SC2086
      systemd-run --unit="nix-upload-$(date +%s%N)" \
        --description="Upload Nix paths to cache" \
        --no-block \
        env NIX_SSHOPTS="-o StrictHostKeyChecking=accept-new" \
        nix copy --to "ssh-ng://build@''${UPLOAD_HOST}" $OUT_PATHS
    fi
  '';
}
