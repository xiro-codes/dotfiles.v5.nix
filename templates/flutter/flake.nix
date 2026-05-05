{
  description = "Flutter development environment";

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
        { pkgs, system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };

          fhs = pkgs.buildFHSEnv {
            name = "flutter-env";
            targetPkgs =
              pkgs: with pkgs; [
                flutter
                dart
                jdk17
                android-tools
                cacert
                zlib
                ncurses5
                stdenv.cc.cc.lib
                curl
              ];
            profile = ''
              export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              export JAVA_HOME="${pkgs.jdk17.home}"
              export ANDROID_HOME="$HOME/Android/Sdk"
              export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
            '';
            runScript = "bash -c 'echo -e \"\\e[34m🐦 Flutter FHS Shell Loaded\\e[0m\"; if [ ! -f pubspec.yaml ]; then echo \"=> No pubspec.yaml found. Run \\'flutter create .\\' to initialize.\"; fi; echo \"Run \\'direnv allow\\' to automatically load this environment.\"; exec bash'";
          };
        in
        {
          formatter = pkgs.nixfmt;
          devShells.default = fhs.env;
        };
    };
}