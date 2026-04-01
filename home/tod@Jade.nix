{ inputs, pkgs, ... }:
{
  imports = [
    ./profiles/server
  ];

  # Server-specific secrets
  local.secrets.keys = [ "gemini/api_key" ];

  # Add ai-commit package
  home.packages = (with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
    ai-commit
  ]) ++ (with pkgs;
    [
      crush
    ]);

  home.stateVersion = "25.11";
}
