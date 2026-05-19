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

        environment.etc."ssh/id_rsa_builder" = {
          text = ''
            -----BEGIN OPENSSH PRIVATE KEY-----
            b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
            QyNTUxOQAAACCO9t9TmsKPnCHFlNthtKn1oeTe+69J3l5dGUk1i0M/nwAAAJjx/trs8f7a
            7AAAAAtzc2gtZWQyNTUxOQAAACCO9t9TmsKPnCHFlNthtKn1oeTe+69J3l5dGUk1i0M/nw
            AAAEASAb0ZSYeo1GJtsMSGkMJW8QAJ2c8mDHEIRlOUND+8Wo7231Oawo+cIcWU22G0qfWh
            5N77r0neXl0ZSTWLQz+fAAAAE2J1aWxkQGluc3RhbGxlci1pc28BAg==
            -----END OPENSSH PRIVATE KEY-----
          '';
          mode = "0600";
        };

        users.motd = ''
          =======================================================================
          Welcome to the NixOS Installer!

          The 'sapphire' and 'ruby' remote builders are fully configured and trusted out of the box!
          Nix will automatically offload builds to sapphire and ruby.

          Happy building!
          =======================================================================
        '';

        programs.ssh.extraConfig = ''
          Host ${config.local.network-hosts.sapphire} sapphire
            User build
            IdentityFile /etc/ssh/id_rsa_builder
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null

          Host ${config.local.network-hosts.ruby} ruby
            User build
            IdentityFile /etc/ssh/id_rsa_builder
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
        '';

        nix = {
          settings.max-jobs = 0;
          ignore-prefer-local-build = true;
          distributedBuilds = true;
          buildMachines = [
            {
              hostName = config.local.network-hosts.sapphire;
              system = "x86_64-linux";
              protocol = "ssh-ng";
              maxJobs = 8;
              sshKey = "/etc/ssh/id_rsa_builder";
              sshUser = "build";
              supportedFeatures = [
                "nixos-test"
                "benchmark"
                "big-parallel"
                "kvm"
              ];
            }
            {
              hostName = config.local.network-hosts.ruby;
              system = "x86_64-linux";
              protocol = "ssh-ng";
              maxJobs = 24;
              sshKey = "/etc/ssh/id_rsa_builder";
              sshUser = "build";
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
