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
    #self.nixosModules.cache
    self.nixosModules.network-hosts
    inputs-nix.nixosModules.default
    {
      local = {
        #cache.enable = true;
        nix-core-settings.enable = true;
      };
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
      boot.zfs.forceImportRoot = false;
      users.motd = ''

        ╔═══════════════════════════════════════════════════════════════╗
        ║                                                               ║
        ║           🚀 NixOS Custom Installer Environment 🚀            ║
        ║                                                               ║
        ╚═══════════════════════════════════════════════════════════════╝

        📦 Auto-Setup:
        ────────────────────────────────────────────────────────────────

        The dotfiles repository will be automatically cloned and
        the nix development shell will be launched.

        Once inside, you can install the system:
            just install <HOSTNAME>

        ────────────────────────────────────────────────────────────────
        💡 Tips:
           • Run 'fastfetch' to see system info
           • Available hosts: Ruby, Sapphire
           • Use 'just rescue' for emergency system recovery
        ────────────────────────────────────────────────────────────────

      '';

      environment.systemPackages = [
        inputs.nixpkgs.legacyPackages.x86_64-linux.python3
        inputs.nixpkgs.legacyPackages.x86_64-linux.git
        inputs.nixpkgs.legacyPackages.x86_64-linux.parted
        inputs.nixpkgs.legacyPackages.x86_64-linux.util-linux
        inputs.nixpkgs.legacyPackages.x86_64-linux.fastfetch
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
      users.mutableUsers = true;
      users.users.nixos = {
        password = "installer";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      users.users.root.password = "installer";

      networking.hostName = "installer";

      # Show IP in MOTD
      systemd.services.update-motd = {
        description = "Update MOTD with IP address";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1 || echo "unknown")
          sed -i "s/🚀 NixOS Custom Installer Environment 🚀/🚀 NixOS Installer ($IP) 🚀/" /etc/motd
        '';
      };
    }
  ];
}).config.system.build.isoImage
