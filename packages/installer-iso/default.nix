{
  inputs,
  self,
  inputs-nix,
  ...
}:
(inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs self inputs-nix;
    currentHostUsers = [ ];
  };
  modules = [
    self.nixosModules.nix-cache-client
    self.nixosModules.nix-builders

    self.nixosModules.network-hosts
    inputs-nix.nixosModules.default
    (
      { config, ... }:
      {
        local = {
          #cache.enable = true;
          nix-core-settings.enable = true;
          nix-cache-client.enable = false;
          nix-builders.enable = true;
        };
        determinate.enable = true;
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        boot.zfs.forceImportRoot = false;
        boot.tmp.tmpfsSize = "8G";
        fileSystems."/".options = [ "size=8G" ];
        environment.systemPackages = [
          inputs.nixpkgs.legacyPackages.x86_64-linux.python3
          inputs.nixpkgs.legacyPackages.x86_64-linux.git
          inputs.nixpkgs.legacyPackages.x86_64-linux.parted
          inputs.nixpkgs.legacyPackages.x86_64-linux.util-linux
          inputs.nixpkgs.legacyPackages.x86_64-linux.fastfetch
          inputs.nixpkgs.legacyPackages.x86_64-linux.nix-output-monitor
        ];

        fonts = {
          enableDefaultPackages = true;
          packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
            noto-fonts
            noto-fonts-emoji
            noto-fonts-cjk-sans
          ];
        };
        nixpkgs.config.allowUnfree = true;

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = true;
          settings.PermitRootLogin = "yes";
        };

        users.motd = ''
          =======================================================================
          Welcome to the NixOS Installer!

          The 'sapphire' and 'ruby' remote builders are fully configured and trusted out of the box!
          Nix will automatically offload builds to sapphire and ruby.

          Happy building!
          =======================================================================
        '';

        networking.hostName = "installer";

      }
    )
  ];
}).config.system.build.isoImage
