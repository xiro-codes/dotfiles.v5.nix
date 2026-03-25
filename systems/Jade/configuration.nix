{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    #./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
  ];

  local = {
    # System settings
    disks.enable = true;
    secrets.enable = lib.mkForce false;
    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "harmonia_key"
      "onix_creds"
      "gog_creds"
    ];
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  system.stateVersion = "25.11";
}
