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

    self.nixosModules.network-hosts
    inputs-nix.nixosModules.default
    (
      { config, ... }:
      {
        local = {
          #cache.enable = true;
          nix-core-settings.enable = true;
          nix-cache-client.enable = true;

        };
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

          To use the 'ruby' remote builder for fast builds:
          Run this command on the ruby host to copy its key over to this ISO:
          `scp /root/.ssh/id_ed25519 root@<ISO_IP>:/root/.ssh/id_rsa_builder`
          (Find this ISO's IP by running `ip a`)

          The remote builder will then be automatically used for Nix commands!
          =======================================================================
        '';

        programs.ssh.extraConfig = ''
          Host ${config.local.network-hosts.ruby} ruby
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
        '';

        nix = {
          distributedBuilds = true;
          buildMachines = [
            {
              hostName = config.local.network-hosts.ruby;
              system = "x86_64-linux";
              protocol = "ssh-ng";
              maxJobs = 8;
              sshKey = "/root/.ssh/id_rsa_builder";
              sshUser = "root";
              supportedFeatures = [
                "nixos-test"
                "benchmark"
                "big-parallel"
                "kvm"
              ];
            }
          ];
        };

        networking.hostName = "installer";

      }
    )
  ];
}).config.system.build.isoImage
