{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/server.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix

  ];
  services.openssh.enable = true;
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  system.stateVersion = "25.11";
}
