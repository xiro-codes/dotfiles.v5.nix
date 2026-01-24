{
	description = "";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		flake-parts.url = "github:hercules-ci/flake-parts";
		nixvim = {
			url = "github:nix-community/nixvim";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	outputs = inputs@{flake-parts, ...}:
	flake-parts.lib.mkFlake { inherit inputs;} {
		systems = ["x86_64-linux"]; 
		imports = [
			./parts/discovery.nix
		];
		perSystem = { config, pkgs, ...}: {
			devShells.default = pkgs.mkShell {
				buildInputs = [ pkgs.git ];
			};		
		};
	};
}
