{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nix-metrics-collector";
  runtimeInputs = with pkgs; [
    coreutils
    procps
    gnugrep
    gawk
    nix
  ];
  text = ''
    mkdir -p /var/lib/prometheus-node-exporter-text-files
    TMP_FILE=$(mktemp)

    # Number of derivations currently building (approximation by checking nix processes)
    BUILDING=$(pgrep -c -x nix-daemon || true)
    echo "nix_derivations_building $BUILDING" >> "$TMP_FILE"

    # Size of the Nix store in bytes
    STORE_SIZE=$(du -sb /nix/store | awk '{print $1}')
    echo "nix_store_size_bytes $STORE_SIZE" >> "$TMP_FILE"

    # Number of files that will get garbage collected (approx by finding dead store paths)
    # This can be slow, so we just run a quick GC dry-run
    GC_DRY=$(nix-store --gc --print-dead 2>/dev/null | wc -l || true)
    echo "nix_dead_store_paths $GC_DRY" >> "$TMP_FILE"

    mv "$TMP_FILE" /var/lib/prometheus-node-exporter-text-files/nix-metrics.prom
  '';
}
