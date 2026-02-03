{ pkgs, config, lib, ...}: let 
  cfg = config.local.variables;
  mkStrOpt = (default: lib.mkOption { type = lib.types.str; default = default; });
in {
  options.local.variables = {
    enable = lib.mkEnableOption "System variables";
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default terminal text editor";
    };
    guiEditor = lib.mkOption {
      type = lib.types.str;
      default = "neovide";
      description = "Default GUI text editor";
    };
    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "ranger";
      description = "Default terminal file manager";
    };
    guiFileManager = lib.mkOption {
      type = lib.types.str;
      default = "pcmanfm";
      description = "Default GUI file manager";
    };
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
    launcher = lib.mkOption {
      type = lib.types.str;
      default = "rofi -show drun";
      description = "Default application launcher command";
    };
    wallpaper = lib.mkOption {
      type = lib.types.str;
      default = "hyprpaper";
      description = "Default wallpaper daemon";
    };
    browser = lib.mkOption {
      type = lib.types.str;
      default = "firefox";
      description = "Default web browser";
    };
    statusBar = lib.mkOption {
      type = lib.types.str;
      default = "hyprpanel";
      description = "Default status bar/panel";
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
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
