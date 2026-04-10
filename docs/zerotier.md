```markdown
# zerotier

This module configures and enables ZeroTier, a virtual network, on your system.  It automatically joins a specified ZeroTier network by retrieving the Network ID from a SOPS secret. This ensures that the system connects to your ZeroTier network during boot.

## Options

This module provides the following configurable options:

### `local.zerotier.enable`

  *   **Type:** `boolean`
  *   **Default:** `false`
  *   **Description:** Enables the ZeroTier virtual network integration. When set to `true`, it configures and starts the `zerotierone` service and a systemd service to join the specified ZeroTier network.

### `local.zerotier.networkIdSecret`

  *   **Type:** `string`
  *   **Default:** `"zerotier_network_id"`
  *   **Description:** The name of the SOPS secret containing the ZeroTier network ID. The system will use this secret to retrieve the Network ID used to join the ZeroTier network. The path to this secret must be defined in `config.sops.secrets.<name>.path`.

## Details

When `local.zerotier.enable` is set to `true`, the module does the following:

1.  **Enables the `zerotierone` service:** This starts the core ZeroTier service, allowing your system to participate in the virtual network.

2.  **Creates a systemd service `zerotier-join`:**  This service is responsible for joining the ZeroTier network specified by the `networkIdSecret`.

    *   **Description:** "Join ZeroTier Network from Secret".
    *   **After:**  Ensures that this service runs after the `zerotierone.service` has started.
    *   **Wants:** Declares a dependency on the `zerotierone.service`.
    *   **WantedBy:** Sets the service to be started during the `multi-user.target` stage of the boot process.
    *   **Service Configuration:**
        *   `Type`: set to `"oneshot"` so that it only runs once during startup.
        *   `RemainAfterExit`: set to `true` so the service manager knows it has successfully ran the command.

    *   **Script:**
        *   Checks if the SOPS secret file specified by `config.sops.secrets."${cfg.networkIdSecret}".path` exists.
        *   If the secret file exists, it retrieves the ZeroTier network ID from the file.
        *   It then waits for the `zerotierone` service to be ready using a retry loop of one second.
        *   It uses `zerotier-cli join "$NETWORK_ID"` to join the specified network.
        *   If the network ID is empty or the secret file is not found, the script exits with an error message.

## Usage Example

To enable ZeroTier and configure it to join a network using a SOPS secret named `my_zerotier_network_id`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    # ... other imports
  ];

  local.zerotier.enable = true;
  local.zerotier.networkIdSecret = "my_zerotier_network_id";

  sops.secrets.my_zerotier_network_id = {
    neededForUsers = true;
    sopsFile = ./secrets/zerotier_network_id.enc; # Replace with the actual path to your encrypted secret file
  };
}
```

**Note:** Make sure that the `sops` module is correctly configured and that the `sopsFile` path points to your encrypted SOPS secret file. Also, remember to properly encrypt the ZeroTier network ID using SOPS.
```
