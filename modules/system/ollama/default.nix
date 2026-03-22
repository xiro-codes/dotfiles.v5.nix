{ config, lib, pkgs, ... }:
let

  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;
  cfg = config.local.ollama;
in
{
  options.local.ollama = {
    enable = mkEnableOption "Ollama vulkan setup";
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "HTTP port for open webui";
    };
  };
  config = mkIf (cfg.enable) {
    services = {
      open-webui = {
        enable = true;
        port = cfg.port;
        openFirewall = true;
      };

      ollama = {
        enable = true;
        openFirewall = true;
        package = pkgs.ollama-vulkan;
        syncModels = true;
        loadModels = [
          "qwen3"
        ];
      };
    };
    hardware.graphics = {
      enable = true;
    };
  };
}

