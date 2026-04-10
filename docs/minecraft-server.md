```markdown
# minecraft-server

This module provides a way to easily deploy and manage a Minecraft server on NixOS. It allows for both imperative and declarative configuration of the server, including whitelisting players and setting server properties. It also handles user creation, file management, and systemd service configuration.

## Options

Here's a detailed breakdown of the available options:

### `local.minecraft-server.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**
    If enabled, this option starts a Minecraft Server. The server data will be loaded from and saved to the directory specified by `local.minecraft-server.dataDir`.

### `local.minecraft-server.declarative`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**
    Determines whether to use a declarative Minecraft server configuration.  When set to `true`, the `local.minecraft-server.whitelist` and `local.minecraft-server.serverProperties` options are applied.  Setting this to true will tell the server to use your specified whitelist and server properties. This also creates a hidden file named `.declarative` in the dataDir to remember that it is in declarative mode.

### `local.minecraft-server.eula`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**
    This option indicates your agreement to Mojang's EULA. This option *must* be set to `true` to run the Minecraft server.  The EULA can be found at [https://account.mojang.com/documents/minecraft_eula](https://account.mojang.com/documents/minecraft_eula).
    The module includes an assertion that checks that this is set to true, and will not start unless it does.

### `local.minecraft-server.dataDir`

*   **Type:** `types.path`
*   **Default:** `"/var/lib/minecraft"`
*   **Description:**
    Specifies the directory to store the Minecraft server's database and other state/data files.  This is where the world data, player data, server properties, and whitelist are stored.  The user account that runs the server will also have its home directory set to this value.

### `local.minecraft-server.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**
    Determines whether to automatically open the necessary ports in the NixOS firewall for the Minecraft server. If `declarative` is `true`, it uses ports specified in `serverProperties`. If not, it opens the default Minecraft server port (25565). This helps make the server accessible from the internet.

### `local.minecraft-server.whitelist`

*   **Type:** `types.attrsOf minecraftUUID` where `minecraftUUID` is a string matching the UUID format `[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}`
*   **Default:** `{}`
*   **Description:**
    Defines the whitelisted players for the Minecraft server. It only has an effect when `local.minecraft-server.declarative` is set to `true` *and* the whitelist is enabled in `local.minecraft-server.serverProperties` by setting `white-list` to `true`.  The value is a mapping from Minecraft usernames to their corresponding UUIDs.  You can use websites like [https://mcuuid.net/](https://mcuuid.net/) to retrieve a Minecraft UUID for a given username.
*   **Example:**

    ```nix
    {
      username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
      username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
    }
    ```

### `local.minecraft-server.serverProperties`

*   **Type:** `types.attrsOf (oneOf [ bool int str ])`
*   **Default:** `{}`
*   **Description:**
    Configures the Minecraft server properties defined in the `server.properties` file. This option only takes effect when `local.minecraft-server.declarative` is set to `true`. Refer to the official Minecraft documentation for detailed information on each property: [https://minecraft.gamepedia.com/Server.properties#Java_Edition_3](https://minecraft.gamepedia.com/Server.properties#Java_Edition_3). This is extremely important for things like setting difficulty, gamemode, motd, and more.
*   **Example:**

    ```nix
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
    ```

### `local.minecraft-server.package`

*   **Type:** `package`
*   **Description:**
    Specifies the Minecraft server package to use.
*   **Example:** `"minecraft-server_1_12_2"`

### `local.minecraft-server.jvmOpts`

*   **Type:** `types.separatedString " "`
*   **Default:** `"-Xmx2048M -Xms2048M"`
*   **Description:**
    Defines the JVM options to be passed to the Minecraft server. These options control the memory allocation, garbage collection, and other aspects of the Java Virtual Machine. This can drastically change performance.
*   **Example:**

    ```nix
    "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
    + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
    + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"
    ```
```
