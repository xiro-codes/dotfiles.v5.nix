{ pkgs, config, lib, inputs, ... }: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../profiles/base.nix
    ../profiles/limine-uefi.nix
    ../profiles/server
  ];
  local = {
    network = {
      enable = true;
      usePihole = true;
    };

    kmscon.enable = true;
    virtualisation.incus = {
      enable = true;
      ui.enable = true;
      macvlanInterface = "enp6s0";
      storageSource = "/media/storage/incus";
    };
    # System settings
    disks.enable = true;
    network-hosts.useAvahi = true;
    bootloader.recoveryUUID = "017aa821-7b75-492a-98cf-1174f1b15ea1";
    docs.enable = lib.mkForce false;
    media = {
      jellyfin.enable = lib.mkForce false;
      ersatztv.enable = lib.mkForce false;
    };

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
    ];
    gog-downloader = {
      enable = true;
      directory = "/media/Media/games";
      secretFile = config.sops.secrets."gog_creds".path;
    };
    zerotier.enable = true;
  };
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          action.lookup("program") == "/run/current-system/sw/bin/nixos-container" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  users.users.tod = {
    shell = pkgs.fish;
    initialPassword = "rockman";
  };

  boot = {
    swraid.mdadmConf = "MAILADDR root";
    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  };

  networking.nftables.enable = true;
  networking.nameservers = lib.mkForce [ "192.168.1.65" "8.8.8.8" ];


  containers.jade = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ "enp6s0" ];
    path = inputs.self.nixosConfigurations.Jade.config.system.build.toplevel;
  };



  system.stateVersion = "25.11";
}
