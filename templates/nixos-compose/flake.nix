{
  description = "garnix-io nixos-compose setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-compose = {
      url = "github:garnix-io/nixos-compose";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-compose,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (
            { pkgs, ... }:
            {
              system.stateVersion = "24.11";

              # Minimal configuration for the VM
              users.users.testuser = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                password = "test";
              };

              # Allow password auth for testing if needed
              services.openssh.enable = true;
              services.openssh.settings.PasswordAuthentication = true;

              # Add any packages you need in the VM
              environment.systemPackages = with pkgs; [
                htop
                curl
              ];
            }
          )
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          nixos-compose.packages.${system}.default
        ];

        shellHook = ''
          echo "garnix-io nixos-compose environment loaded"
          echo "Run 'just up' to start the test-vm"
        '';
      };
    };
}
