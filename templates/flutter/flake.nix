{
  description = "Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        fhs = pkgs.buildFHSEnv {
          name = "flutter-env";
          targetPkgs = pkgs: with pkgs; [
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
        devShells.default = fhs.env;
      }
    );
}
