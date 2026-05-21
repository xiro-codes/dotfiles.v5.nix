let
  flake = builtins.getFlake (toString ./.);
  inputs = flake.inputs;
  system = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ { fileSystems."/".device = "/dev/null"; boot.loader.grub.device = "/dev/null"; } ];
  };
in
  system.config.system.build.toplevel.outPath
