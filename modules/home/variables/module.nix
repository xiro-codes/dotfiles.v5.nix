{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.local.variables;
in
{
  options.local.variables = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system environment variables for common tools and applications";
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of commands or programs to autostart (consumed by Hyprland or similar WMs)";
    };
    editor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default terminal text editor";
    };
    guiEditor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default GUI text editor";
    };
    fileManager = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default terminal file manager";
    };
    guiFileManager = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default GUI file manager";
    };
    terminal = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default terminal emulator";
    };
    launcher = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default application launcher command";
    };
    wallpaper = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default wallpaper daemon or manager";
    };
    browser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default web browser";
    };
    statusBar = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default status bar or panel application";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.global-just
    ];
    home.sessionVariables = lib.filterAttrs (n: v: v != null) {
      EDITOR = cfg.editor;
      VISUAL = cfg.editor;
      GUI_EDITOR = cfg.guiEditor;
      FILEMANAGER = cfg.fileManager;
      GUI_FILEMANAGER = cfg.guiFileManager;
      TERMINAL = cfg.terminal;
      GUI_TERMINAL = cfg.terminal;
      LAUNCHER = cfg.launcher;
      BROWSER = cfg.browser;
      WALLPAPER = cfg.wallpaper;
      STATUS_BAR = cfg.statusBar;
    };
  };
}
