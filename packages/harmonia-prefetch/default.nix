{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "prefetch";
  runtimeInputs = with pkgs; [
    git
    nix
    coreutils
    gnused
  ];
  text = ''
    FLAKE_PATH=$1
    shift
    HOSTS=("$@")

    nix --version
    cd "$FLAKE_PATH"
    nix flake update

    for TARGET in "''${HOSTS[@]}"; do
      echo "Prefetching for $TARGET..."
      nix build --impure .#nixosConfigurations."$TARGET".config.system.build.toplevel --no-link
    done
  '';
}
