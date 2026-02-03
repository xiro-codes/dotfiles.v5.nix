{ inputs, ... }:
(inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.self.nixosModules.cache
    inputs.self.nixosModules.settings
    {
      local = {
        cache.enable = true;
        settings.enable = true;
      };
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      users.motd = ''
        Custom NixOS Installer
        1. git clone http://10.0.0.65:3002/xiro/dotfiles.nix.git
        2. cd dotfiles.nix
        3. nix develop
        4. just install HOSTNAME
      '';

      environment.etc."dotfiles-src".source = builtins.path {
        path = inputs.self.outPath;
        name = "dotfiles-git-src";
        filter = path: type: true;
      };
      environment.systemPackages =
        [
          inputs.nixpkgs.legacyPackages.x86_64-linux.python3
          inputs.nixpkgs.legacyPackages.x86_64-linux.git
          inputs.nixpkgs.legacyPackages.x86_64-linux.parted
          inputs.nixpkgs.legacyPackages.x86_64-linux.util-linux
          inputs.self.packages.x86_64-linux.install-system
        ];
      nixpkgs.config.allowUnfree = true;

      networking.hostName = "installer";
    }
  ];
}).config.system.build.isoImage
