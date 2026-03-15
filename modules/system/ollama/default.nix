{ config, lib, pkgs, ... }:
let

  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;
  cfg = config.local.ollama;
in
{
  options.local.ollama = {
    enable = mkEnableOption "Ollama vulkan setup";
  };
  config = mkIf (cfg.enable) {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
    };
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
      ];
    };
  };
}

