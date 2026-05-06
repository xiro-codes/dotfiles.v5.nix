{
  pkgs,
  inputs,
  ...
}:
pkgs.mkShell {
  name = "dotfiles-shell";
  nativeBuildInputs = with pkgs; [
    home-manager
    git
    just
    nh
    nix-output-monitor
    nvd
    inputs.inputs-nix.inputs.deploy-rs.packages.x86_64-linux.deploy-rs
    gitlogue
    nixfmt-tree
    gource
  ];
  packages = with pkgs; [
    caligula
  ];
  shellHook = ''
    echo "❄️ Welcome to your NixOS Flake DevShell"
  '';
}
