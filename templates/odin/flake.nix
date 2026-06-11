{
  description = "A standard Odin project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          packages.default = pkgs.stdenv.mkDerivation {
            pname = "odin-app";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = [ pkgs.odin ];

            buildPhase = ''
              runHook preBuild
              # Set HOME because Odin sometimes needs it for cache
              export HOME=$(pwd)
              odin build src -out:bin/main -strict-style
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp bin/main $out/bin/
              runHook postInstall
            '';
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              odin
              ols
            ];

            shellHook = ''
              echo "🗡️ Odin Dev Environment Loaded"
              echo "Odin version: $(odin version)"
              echo "Run 'direnv allow' to automatically load this environment."
            '';
          };
        };
    };
}
