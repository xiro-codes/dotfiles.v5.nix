{ pkgs, lib, ... }:
let
  inherit (lib) getExe generators;
  configFile = pkgs.writeText "config.yaml" (
    generators.toYAML { } {
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
pkgs.writeShellApplication {
  name = "quick-menu";
  text = ''
    exec ${getExe pkgs.wlr-which-key} ${configFile}
  '';
}
