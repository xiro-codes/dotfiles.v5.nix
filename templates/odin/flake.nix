{
  description = "A standard Odin project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
