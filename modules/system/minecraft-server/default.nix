{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
with lib;
let
  cfg = config.local.minecraft-server;

  # We don't allow eula=false anyways
  eulaFile = builtins.toFile "eula.txt" ''
    # eula.txt managed by NixOS Configuration
    eula=true
  '';

  whitelistFile = pkgs.writeText "whitelist.json" (
    builtins.toJSON (
      mapAttrsToList (n: v: {
        name = n;
        uuid = v;
      }) cfg.whitelist
    )
  );

  cfgToString = v: if builtins.isBool v then boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (
    ''
      # server.properties managed by NixOS configuration
    ''
    + concatStringsSep "\n" (mapAttrsToList (n: v: "${n}=${cfgToString v}") cfg.serverProperties)
  );

  stopScript = "${
    self.packages.${pkgs.stdenv.hostPlatform.system}.minecraft-server-stop
  }/bin/minecraft-server-stop";

  queryPort =
    if cfg.serverProperties.enable-query or false then
      cfg.serverProperties."query.port" or 25565
    else
      null;
in
{
  options = {
    local.minecraft-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Server. The server
          data will be loaded from and saved to
          {option}`services.minecraft-server.dataDir`.
        '';
      };

      declarative = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use a declarative Minecraft server configuration.
          Only if set to `true`, the options
          {option}`services.minecraft-server.whitelist` and
          {option}`services.minecraft-server.serverProperties` will be
          applied.
        '';
      };

      eula = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether you agree to
          [
          Mojangs EULA](https://account.mojang.com/documents/minecraft_eula). This option must be set to
          `true` to run Minecraft server.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/minecraft";
        description = ''
          Directory to store Minecraft database and other state/data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for the server.
        '';
      };

      whitelist = mkOption {
        type =
          let
            minecraftUUID =
              types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
              // {
                description = "Minecraft UUID";
              };
          in
          types.attrsOf minecraftUUID;
        default = { };
        description = ''
          Whitelisted players, only has an effect when
          {option}`services.minecraft-server.declarative` is
          `true` and the whitelist is enabled
          via {option}`services.minecraft-server.serverProperties` by
          setting `white-list` to `true`.
          This is a mapping from Minecraft usernames to UUIDs.
          You can use <https://mcuuid.net/> to get a
          Minecraft UUID for a username.
        '';
        example = literalExpression ''
          {
            username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
          };
        '';
      };

      serverProperties = mkOption {
        type =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
        default = { };
        example = literalExpression ''
          {
            server-port = 43000;
            difficulty = 3;
            gamemode = 1;
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "hunter2";
          }
        '';
        description = ''
          Minecraft server properties for the server.properties file. Only has
          an effect when {option}`services.minecraft-server.declarative`
          is set to `true`. See
          <https://minecraft.gamepedia.com/Server.properties#Java_Edition_3>
          for documentation on these values.
        '';
      };

      package = mkPackageOption pkgs "minecraft-server" {
        example = "minecraft-server_1_12_2";
      };

      jvmOpts = mkOption {
        type = types.separatedString " ";
        default = "-Xmx2048M -Xms2048M";
        # Example options from https://minecraft.gamepedia.com/Tutorials/Server_startup_script
        example =
          "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
          + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
          + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
        description = "JVM options for the Minecraft server.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.minecraft = {
      description = "Minecraft server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "minecraft";
    };
    users.groups.minecraft = { };

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mc-console
    ]
    ++ optional (cfg.serverProperties.enable-rcon or false) pkgs.mcrcon;

    systemd.sockets.minecraft-server = {
      bindsTo = [ "minecraft-server.service" ];
      socketConfig = {
        ListenFIFO = "/run/minecraft-server.stdin";
        SocketMode = "0660";
        SocketUser = "minecraft";
        SocketGroup = "minecraft";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };

    systemd.services.minecraft-server = {
      description = "Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "minecraft-server.socket" ];
      after = [
        "network.target"
        "minecraft-server.socket"
      ];
      path = [ pkgs.bash ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/minecraft-server ${cfg.jvmOpts}";
        ExecStop = "${stopScript} ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO} $MAINPID";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = cfg.dataDir;

        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      preStart = ''
        ln -sf ${eulaFile} eula.txt
      ''
      + (
        if cfg.declarative then
          ''

            if [ -e .declarative ]; then

              # Was declarative before, no need to back up anything
              ln -sf ${whitelistFile} whitelist.json
              cp -f ${serverPropertiesFile} server.properties

            else

              # Declarative for the first time, backup stateful files
              ln -sb --suffix=.stateful ${whitelistFile} whitelist.json
              cp -b --suffix=.stateful ${serverPropertiesFile} server.properties

              # server.properties must have write permissions, because every time
              # the server starts it first parses the file and then regenerates it..
              chmod +w server.properties
              echo "Autogenerated file that signifies that this server configuration is managed declaratively by NixOS" \
                 > .declarative

            fi
          ''
        else
          ''
            if [ -e .declarative ]; then
              rm .declarative
            fi
          ''
      );
    };

    networking.firewall = mkIf cfg.openFirewall (
      if cfg.declarative then
        {
          allowedUDPPorts = [
            # serverPort
          ];
          allowedTCPPorts = [
            # serverPort
          ]
          ++ optional (queryPort != null) queryPort;
          # ++ optional (rconPort != null) rconPort;
        }
      else
        {
          allowedUDPPorts = [ defaultServerPort ];
          allowedTCPPorts = [ defaultServerPort ];
        }
    );

    assertions = [
      {
        assertion = cfg.eula;
        message =
          "You must agree to Mojangs EULA to run minecraft-server."
          + " Read https://account.mojang.com/documents/minecraft_eula and"
          + " set `services.minecraft-server.eula` to `true` if you agree.";
      }
    ];
  };
}
