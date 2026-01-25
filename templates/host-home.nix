{pkgs, ...}: {
  home.stateVersion = "25.11";
  local = {
    variables.enable = true;
    TEMPLATE_DESKTOP.enable = true;
  };
}
