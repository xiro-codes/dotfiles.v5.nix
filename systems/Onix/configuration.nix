{ pkgs, config, lib, inputs, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];
  local = {
    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;
      jvmOpts = "-Xms6G -Xmx6G";
      package = inputs.self.packages.${pkgs.system}.tekkit-server;
      serverProperties = {
        server-port = 25565;
        difficulty = 1;
        gamemode = 0;
        max-players = 10;
        motd = "Tekkit Server on Onix";
      };
    };
    network = {
      enable = true;
      usePihole = true;
    };

    kmscon.enable = false;
    virtualisation.incus = {
      enable = false;
      ui.enable = true;
      macvlanInterface = "enp6s0";
      storageSource = "/media/storage/incus";
    };
    # System settings
    disks.enable = true;
    network-hosts.useAvahi = true;
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";

    secrets.keys = [
      "gemini/api_key"
      "ssh_pub_ruby/master"
      "ssh_pub_sapphire/master"
      "ssh_pub_onix/master"
      "ssh_pub_jade/master"
      "harmonia_key"
      "onix_creds"
      "gog_creds"
      "zerotier_network_id"
      "gitea/runner_token"
    ];
    gog-downloader = {
      enable = false;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
    zerotier.enable = true;
    containers.Jade.enable = true;
  };

  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  boot = {
    swraid.mdadmConf = "MAILADDR root";
    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  };

  networking.nftables.enable = true;



  system.stateVersion = "25.11";
}
