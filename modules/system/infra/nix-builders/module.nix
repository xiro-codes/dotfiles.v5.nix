{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    filter
    mkEnableOption
    mkIf
    mkOption
    toLower
    types
    ;

  cfg = config.local.nix-builders;

  # Filter out the current host itself from the builders list to avoid self-loop connections
  activeHosts = filter (h: toLower h != toLower config.networking.hostName) cfg.hosts;

  # Default settings for each known builder host
  builderDefs = {
    sapphire = {
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    };
    ruby = {
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 24;
      speedFactor = 8;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    };
  };
in
{
  options.local.nix-builders = {
    enable = mkEnableOption "remote Nix builders";

    sshKey = mkOption {
      type = types.str;
      default = "/etc/ssh/id_rsa_builder";
      description = "Path to the SSH private key for remote builders.";
    };

    sshUser = mkOption {
      type = types.str;
      default = "build";
      description = "SSH user for remote builders.";
    };

    provisionSSHKey = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically write the default builder private key to the sshKey path.";
    };

    hosts = mkOption {
      type = types.listOf types.str;
      default = [
        "sapphire"
        "ruby"
      ];
      description = "List of remote builders to use.";
    };
  };

  config = mkIf cfg.enable {
    # Provision the default SSH key if requested
    environment.etc."ssh/id_rsa_builder" = mkIf cfg.provisionSSHKey {
      text = ''
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACCO9t9TmsKPnCHFlNthtKn1oeTe+69J3l5dGUk1i0M/nwAAAJjx/trs8f7a
        7AAAAAtzc2gtZWQyNTUxOQAAACCO9t9TmsKPnCHFlNthtKn1oeTe+69J3l5dGUk1i0M/nw
        AAAEASAb0ZSYeo1GJtsMSGkMJW8QAJ2c8mDHEIRlOUND+8Wo7231Oawo+cIcWU22G0qfWh
        5N77r0neXl0ZSTWLQz+fAAAAE2J1aWxkQGluc3RhbGxlci1pc28BAg==
        -----END OPENSSH PRIVATE KEY-----
      '';
      mode = "0600";
    };

    # Configure SSH to allow the nix daemon to connect to the builder hosts
    programs.ssh.extraConfig = concatMapStringsSep "\n" (host:
      let
        hostIP =
          if builtins.hasAttr host config.local.network-hosts then
            config.local.network-hosts.${host}
          else
            host;
      in
      ''
        Host ${hostIP} ${host}
          User ${cfg.sshUser}
          IdentityFile ${cfg.sshKey}
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
      ''
    ) activeHosts;

    # Configure Nix distributed builds
    nix = {
      distributedBuilds = true;
      buildMachines = map (host:
        let
          def = builderDefs.${host} or {
            system = "x86_64-linux";
            protocol = "ssh-ng";
            maxJobs = 4;
            speedFactor = 1;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
          };
          hostIP =
            if builtins.hasAttr host config.local.network-hosts then
              config.local.network-hosts.${host}
            else
              host;
        in
        {
          hostName = hostIP;
          sshUser = cfg.sshUser;
          sshKey = cfg.sshKey;
          inherit (def)
            system
            protocol
            maxJobs
            speedFactor
            supportedFeatures
            ;
        }
      ) activeHosts;
    };
  };
}
