{ pkgs, ... }:
{
  imports = [
    ../base
    ../desktop
  ];

  # Workstation-specific secrets
  local.secrets.keys = [
    "gemini/api_key"
    "gemini/crush_agent_key"
  ];

  home.packages = with pkgs; [
    godot
    eog
    prismlauncher
    geminicommit
    crush
    antigravity-fhs
    z-library-desktop
    (symlinkJoin {
      name = "xivlauncher-wrapped";
      paths = [ xivlauncher ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/XIVLauncher.Core --set XL_SECRET_PROVIDER FILE
      '';
    })
  ];

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    matches.base.matches = [
      {
        trigger = "dto";
        replace = "dot";
        word = true;
      }
    ];
  };
}
