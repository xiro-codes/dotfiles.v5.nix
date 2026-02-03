{ pkgs
, config
, lib
, ...
}:
let
  cfg = config.local.nixvim;
  inherit (lib) mkOption mkIf types;
in
{
  options.local.nixvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nixvim configuration";
    };
    rust = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Rust language support";
    };
    smartUndo = mkOption {
      type = types.bool;
      default = true;
      description = "Enable persistent undo with smart directory management";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-fmt
      neovide
      lazygit
    ];
    programs.nixvim =
      let
        baseOptions = import ./options.nix { inherit config lib; };
        dashboard = import ./dashboard.nix { };
        plugins = import ./plugins.nix { inherit pkgs config lib; };
        keymaps = import ./keymaps.nix { inherit pkgs config lib; };
      in
      {
        enable = true;
        defaultEditor = true;
        #colorscheme = lib.mkForce null;
        inherit (baseOptions) globals opts extraConfigLua;
        inherit keymaps;

        plugins = plugins // {
          alpha = dashboard;
        };

        extraPackages = with pkgs; [
          ripgrep
          fd
          gcc # For treesitter builds
        ];
      };
  };
}
