{
  description = "Test Bevy 0.17.0 Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Generic Rust & Build Tools
          cargo
          rustc
          pkg-config

          # Bevy System Dependencies
          udev
          alsa-lib
          vulkan-loader
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          libxkbcommon
          wayland
        ];

        shellHook = ''
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath (with pkgs; [
            udev alsa-lib vulkan-loader libxkbcommon wayland
          ])}"
          echo "Bevy 0.17.0 Test Environment Loaded"
        '';
      };
    };
}
