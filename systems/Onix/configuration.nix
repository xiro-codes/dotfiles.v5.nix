{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];

  local = {
    # System settings
    disks.enable = true;
    hosts.useAvahi = true;
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "harmonia_key"
      "onix_creds"
      "gog_creds"
    ];
    gog-downloader = {
      enable = true;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  system.stateVersion = "25.11";
}
