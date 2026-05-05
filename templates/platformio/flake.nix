{
  description = "PlatformIO C/C++ Embedded Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/15f4ee454b1dce334612fa6843b3e05cf546efab";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/71a3a77326609675e9f8b51084cf23d5d1945899";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
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
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              platformio
              python3
              python3Packages.pyserial
              clang-tools
              cppcheck
            ];

            shellHook = ''
              echo "🔧 PlatformIO Dev Environment"
              if [ ! -f platformio.ini ]; then
                echo "=> No platformio.ini found. Run 'pio project init -b <board_name>' to start."
              fi
              echo "Run 'pio run' to build, 'pio run -t upload' to flash."
              echo "Run 'direnv allow' to automatically load this environment."
            '';
          };
        };
    };
}