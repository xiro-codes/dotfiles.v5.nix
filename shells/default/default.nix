{ pkgs, ...}: pkgs.mkShell {
    name = "dotfiles-shell";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      just
      nh
      nix-output-monitor
      nvd
    ];
    shellHook = ''
      echo "❄️ Welcome to your NixOS Flake DevShell"
      echo "Commands: nxs (switch), just (automation)"
    '';
}
