{ pkgs, config, lib, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/server.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
  ];

  local = {
    # System settings
    disks.enable = true;
    #hosts.useAvahi = true;

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "onix_creds"
      "gitea/runner_token"
    ];
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };
  systemd.tmpfiles.rules = [
    # "d /media/Media 0777 root root -"
    "d /media/Backups 0777 root root -"
  ];
  networking.firewall = {
    trustedInterfaces = [ "lo" ];
    allowedTCPPortRanges =
      [{
        from = 0;
        to = 65535;
      }];
    allowedUDPPortRanges =
      [{
        from = 0;
        to = 65535;
      }];
  };

  services.docs = {
    enable = true;
    port = 3001;
  };


  boot.mdadm.program = ''
    #!${pkgs.runtimeShell}
    ssh tod@ruby "export DISPLAY=:0; notify-send 'MDADM event on Onix' '$*'"
    ssh tod@sapphire "export DISPLAY=:0; notify-send 'MDADM event on Onix' '$*'"
  '';

  system.stateVersion = "25.11";
}
