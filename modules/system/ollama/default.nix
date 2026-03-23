{ config, lib, pkgs, ... }:
let

  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;
  cfg = config.local.ai;
in
{
  options.local.ai.webui = {
    enable = mkEnableOption "Web ui for ollama";
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "HTTP port for open webui";
    };
  };
  options.local.ai.ollama = {
    enable = mkEnableOption "Ollama vulkan setup";
    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Http port for ollama";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.webui.enable) {
      services.open-webui = {
        enable = true;
        port = cfg.webui.port;
        openFirewall = true;
      };
      hardware.graphics = {
        enable = true;
      };
    })
    (lib.mkIf (cfg.ollama.enable) {
      services.ollama = {
        enable = true;
        openFirewall = true;
        port = cfg.ollama.port;
        package = pkgs.ollama-vulkan;
        host = "0.0.0.0";
        syncModels = true;
        loadModels = [
          "qwen3"
        ];
      };
    })
  ];
}

