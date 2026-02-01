{ pkgs, inputs, ... }: pkgs.mkShell {
  name = "dotfiles-shell";
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git
    just
    nh
    nix-output-monitor
    nvd
    inputs.deploy-rs.packages.x86_64-linux.deploy-rs
    inputs.self.packages.x86_64-linux.template-utils
  ];
  shellHook = ''
    echo "❄️ Welcome to your NixOS Flake DevShell"
  '';
}
