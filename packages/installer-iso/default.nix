{ inputs, ... }:
(inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    #inputs.self.nixosModules.cache
    inputs.self.nixosModules.network-hosts
    inputs.self.nixosModules.nix-core-settings
    {
      local = {
        #cache.enable = true;
        nix-core-settings.enable = true;
        network-hosts.useAvahi = true;
      };
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
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

      services.getty.autologinUser = inputs.nixpkgs.lib.mkForce "nixos";

      environment.loginShellInit = ''
        if [ ! -d "$HOME/dotfiles.v5.nix" ]; then
          echo "📥 Cloning dotfiles repository..."
          git clone https://github.com/xiro-codes/dotfiles.v5.nix "$HOME/dotfiles.v5.nix"
        fi
        cd "$HOME/dotfiles.v5.nix"
        echo "🚀 Entering development shell..."
        exec nix develop
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

      networking.hostName = "installer";
    }
  ];
}).config.system.build.isoImage
