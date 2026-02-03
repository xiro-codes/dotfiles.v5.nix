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
        
        ╔═══════════════════════════════════════════════════════════════╗
        ║                                                               ║
        ║           🚀 NixOS Custom Installer Environment 🚀            ║
        ║                                                               ║
        ╚═══════════════════════════════════════════════════════════════╝
        
        📦 Installation Steps:
        ────────────────────────────────────────────────────────────────
        
        1️⃣  Clone the dotfiles repository:
            git clone http://10.0.0.65:3002/xiro/dotfiles.nix.git
        
        2️⃣  Enter the repository:
            cd dotfiles.nix
        
        3️⃣  Enter development shell:
            nix develop
        
        4️⃣  Install system:
            just install <HOSTNAME>
        
        ────────────────────────────────────────────────────────────────
        💡 Tips:
           • Run 'fastfetch' or 'neofetch' to see system info
           • Available hosts: Ruby, Sapphire
           • Use 'just rescue' for emergency system recovery
        ────────────────────────────────────────────────────────────────
        
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
          inputs.nixpkgs.legacyPackages.x86_64-linux.neofetch
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
