{
  inputs,
  selfPath ? ./.,
}:
{
  globalNixosModules = [
    { _module.args.flake-inputs = inputs; }
    {
      imports = [
        (selfPath + "/modules/system/core/bootloader/module.nix")
        (selfPath + "/modules/system/core/disks/module.nix")
        (selfPath + "/modules/system/networking/network/module.nix")
        (selfPath + "/modules/system/core/nix-core-settings/module.nix")
        (selfPath + "/modules/system/core/secrets/module.nix")
        (selfPath + "/modules/system/admin/security/module.nix")
        (selfPath + "/modules/system/admin/user-manager/module.nix")
        (selfPath + "/modules/system/core/localization/module.nix")
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.gog-nix.nixosModules.gog
        inputs.silentsddm.nixosModules.default
        inputs.harmonia.nixosModules.harmonia
        inputs.determinate.nixosModules.default
        inputs.nix-topology.nixosModules.default
      ];
    }
  ];

  globalHomeModules = [
    {
      imports = [
        inputs.fuchsia-nix.homeModules.default
        inputs.sops-nix.homeModules.sops
        inputs.caelestia-shell.homeManagerModules.default
        inputs.nixvim.homeModules.nixvim
        inputs.stylix.homeModules.stylix
      ];
    }
  ];
}
