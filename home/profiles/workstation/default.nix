{ ... }:
{
  imports = [
    ../base
    ../desktop
  ];

  # Workstation-specific secrets
  local.secrets.keys = [ "gemini/api_key" ];
}
