let
  flake = builtins.getFlake "git+file:///home/tod/.dotfiles.nix";
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  eval = pkgs.lib.evalModules {
    modules = [
      (flake.inputs.nixpkgs.outPath + "/nixos/modules/services/networking/ddns-updater.nix")
      {
        config._module.args = { inherit pkgs; utils = {}; };
      }
    ];
  };
in
builtins.attrNames eval.options.services.ddns-updater
