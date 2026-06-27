{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./hardware-configuration.nix
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  local = {
    nix-core-settings.enable = true;
    harmonia-client.enable = false;
    nix-builders.enable = false;
    
    # Use standard sops-nix security instead of hardcoding SSH keys
    secrets = {
      enable = true;
      keys = [
        "ssh_pub_ruby/master"
        "ssh_pub_sapphire/master"
        "ssh_pub_slate/master"
      ];
    };
    security = {
      enable = true;
      adminUser = "root"; # Prevent implicit creation of 'tod' user on the ISO
    };
  };

  # Provide the static SSH host key for SOPS decryption at boot
  environment.etc."ssh/ssh_host_ed25519_key" = {
    mode = "0600";
    text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACBg8wpKv2p02pEMUg8rV7KJFcKzIQgloPj8HMsH9j5N7wAAAJCzFEqqsxRK
      qgAAAAtzc2gtZWQyNTUxOQAAACBg8wpKv2p02pEMUg8rV7KJFcKzIQgloPj8HMsH9j5N7w
      AAAECNLbmjVNrIuhm9yqveTdL9iY9rrG5gmT3pe37oQL+X4WDzCkq/anTakQxSDytXsokV
      wrMhCCWg+Pwcywf2Pk3vAAAACXJvb3RAU2VlZAECAwQ=
      -----END OPENSSH PRIVATE KEY-----
    '';
  };

  environment.etc."ssh/ssh_host_ed25519_key.pub" = {
    mode = "0644";
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDzCkq/anTakQxSDytXsokVwrMhCCWg+Pwcywf2Pk3v root@Nucleus\n";
  };

  boot.zfs.forceImportRoot = false;
  boot.tmp.tmpfsSize = "8G";
  fileSystems."/".options = [ "size=8G" ];

  environment.systemPackages = with pkgs; [
    python3
    git
    parted
    util-linux
    fastfetch
    nix-output-monitor
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = mkForce "prohibit-password"; # Security module already sets this, but ensure it's forced
  };

  users.motd = ''
    =======================================================================
    Welcome to the Nucleus ISO (NixOS Installer)!

    The Nucleus crystal has booted successfully.
    SOPS-nix is configured, and authorized SSH keys are ready.
    Happy building!
    =======================================================================
  '';

  networking.hostName = "Nucleus";
  
  # Satisfy the standard requirement for stateVersion
  system.stateVersion = "25.11";
}
