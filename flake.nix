{
  description = "NixOS Dotfiles (v5) with automated discovery engine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    inputs-nix.url = "path:/home/tod/WorkSpace/Nix/inputs.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      inputs-nix,
      ...
    }:
    let
      inputs = inputs-nix.inputs // {
        inherit self inputs-nix;
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.nix-topology.flakeModule
        (import ./schemas.nix self.outPath)
        (import ./discovery (
          import ./globals.nix {
            inherit inputs;
            selfPath = ./.;
          }
        ))
      ];
      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          #packages = inputs.nvim-nix.packages.${system};
          topology.modules = [
            ./topology.nix
          ];
        };
    };
}
