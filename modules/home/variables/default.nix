{ pkgs, config, lib, ...}: let 
  cfg = config.local.variables;
  mkStrOpt = (default: lib.mkOption { type = lib.types.str; default = default; });
in {
  options.local.variables = {
    enable = lib.mkEnableOption "System variables";
    editor = mkStrOpt "nvim";
    guiEditor = mkStrOpt "neovide";
    fileManager = mkStrOpt "ranger";
    guiFileManager = mkStrOpt "pcmanfm";
    terminal = mkStrOpt "kitty";
    launcher = mkStrOpt "rofi -show drun";
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
    };
  };
}
