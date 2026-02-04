{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/server.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix

  ];
  local = {
    disks.enable = true;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "zima_creds"
    ];
  };
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  system.stateVersion = "25.11";
}
