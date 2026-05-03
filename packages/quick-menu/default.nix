{ pkgs, lib, ... }:
let
  configFile = pkgs.writeText "config.yaml" (
    lib.generators.toYAML { } {
      anchor = "bottom-right";
      menu = [
        {
          key = "w";
          desc = "Web Browser";
          cmd = "zen";
        }
        {
          key = "f";
          desc = "File Manager";
          cmd = "nautilus";
        }
        {
          key = "v";
          desc = "Volume Control";
          cmd = "pavucontrol";
        }
        {
          key = "d";
          desc = "Discord";
          cmd = "discord";
        }
        {
          key = "g";
          desc = "Big Screen Gaming";
          cmd = "hypr-gaming-mode";
        }
      ];
    }
  );
in
pkgs.writeShellScriptBin "quick-menu" ''
  exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
''
