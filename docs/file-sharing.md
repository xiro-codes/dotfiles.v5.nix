# file-sharing

This module provides a convenient way to configure file sharing services, including NFS and Samba, on NixOS. It allows you to define shares with various options, such as read-only access, guest access, and user-based permissions.  It generates configurations and sets up the necessary services. It also allows for opening firewall ports for these services.

## Options

Here's a detailed breakdown of the available configuration options:

### `local.file-sharing.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables file sharing services. This is a top-level enable option.  When set to true, the module configures NFS and/or Samba based on their individual enable options.

### `local.file-sharing.shareDir`

*   **Type:** `types.str`
*   **Default:** `"/srv/shares"`
*   **Example:** `"/mnt/storage/shares"`
*   **Description:**  The base directory where shared files reside.  It's recommended to use a dedicated directory for shared content. This directory will be created with appropriate permissions when the module is enabled.

### `local.file-sharing.nfs.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the NFS server. If this is enabled, the module configures the `nfs-server.service` and creates the necessary exports based on the `exports` option and the definitions in `definitions`.

### `local.file-sharing.nfs.exports`

*   **Type:** `types.lines`
*   **Default:** `""`
*   **Example:**

    ```nix
    /srv/shares 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
    /srv/media 192.168.1.0/24(ro,sync,no_subtree_check)
    ```

*   **Description:** NFS exports configuration. This option allows you to define NFS exports manually, using the standard NFS export syntax.  Each line represents a single export.  Exports defined here are combined with exports generated from the `definitions` option.

### `local.file-sharing.nfs.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Open firewall ports for NFS.  If enabled, this option configures the NixOS firewall to allow NFS traffic, opening the necessary TCP and UDP ports.

### `local.file-sharing.samba.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the Samba server.  If enabled, the module configures the `samba.service`, creates shares based on the `shares` option and the definitions in `definitions`, and optionally opens firewall ports.

### `local.file-sharing.samba.workgroup`

*   **Type:** `types.str`
*   **Default:** `"WORKGROUP"`
*   **Description:** Samba workgroup name. Specifies the workgroup to which the Samba server belongs.  This should match the workgroup configuration of the clients that will be accessing the shares.

### `local.file-sharing.samba.serverString`

*   **Type:** `types.str`
*   **Default:** `"NixOS File Server"`
*   **Description:** Server description string. A descriptive string that identifies the Samba server. This string is displayed in network browsing lists.

### `local.file-sharing.samba.shares`

*   **Type:** `types.attrsOf (types.attrsOf types.unspecified)`
*   **Default:** `{}`
*   **Example:**

    ```nix
    {
      public = {
        path = "/srv/shares/public";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
      media = {
        path = "/srv/media";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
    }
    ```

*   **Description:** Samba share definitions. This option allows you to define Samba shares manually using a nested attribute set. Each attribute represents a share, and its value is another attribute set containing share-specific options. These shares will be merged with the `definitions` option.

    *   `path`: (string) Absolute path to the shared directory.
    *   `read only`: (string, "yes" or "no")  Specifies whether the share is read-only.
    *   `browseable`: (string, "yes" or "no")  Specifies whether the share is visible in browse lists.
    *   `guest ok`: (string, "yes" or "no")  Specifies whether guest access is allowed without authentication.
    *   Other Samba options can be added here as needed.

### `local.file-sharing.samba.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Open firewall ports for Samba. If enabled, this configures the NixOS firewall to allow Samba traffic, opening the necessary ports (TCP 139, 445 and UDP 137, 138).

### `local.file-sharing.definitions`

*   **Type:** `types.attrsOf (types.submodule { ... })`
*   **Default:** `{}`
*   **Example:**

    ```nix
    {
      media = {
        path = "/srv/media";
        comment = "Media files";
        readOnly = true;
        guestOk = true;
        enableNFS = true;
      };
      documents = {
        path = "/srv/documents";
        comment = "Shared documents";
        validUsers = [ "alice" "bob" ];
      };
    }
    ```

*   **Description:** Structured share definitions that automatically configure both Samba and NFS. This option allows you to define shares in a structured way. Each attribute represents a share.  The properties within each share configuration will be translated into both Samba and NFS configurations.

    The following options are available within each share definition:

    *   **`path`**:
        *   **Type:** `types.path`
        *   **Description:** Absolute path to the share directory.
    *   **`comment`**:
        *   **Type:** `types.str`
        *   **Default:** `""`
        *   **Description:** Description of the share. This will appear as the share comment in Samba.
    *   **`readOnly`**:
        *   **Type:** `types.bool`
        *   **Default:** `false`
        *   **Description:** Whether the share is read-only.
    *   **`guestOk`**:
        *   **Type:** `types.bool`
        *   **Default:** `false`
        *   **Description:** Allow guest access without authentication.
    *   **`browseable`**:
        *   **Type:** `types.bool`
        *   **Default:** `true`
        *   **Description:** Whether the share is visible in browse lists.
    *   **`validUsers`**:
        *   **Type:** `types.listOf types.str`
        *   **Default:** `[]`
        *   **Example:** `[ "alice" "bob" ]`
        *   **Description:** List of users allowed to access (empty = all users). Only relevant for Samba.
    *   **`writeable`**:
        *   **Type:** `types.bool`
        *   **Default:** `true`
        *   **Description:** Whether users can write to the share. Note:  This only has an effect if `readOnly` is set to `false`.
    *   **`createMask`**:
        *   **Type:** `types.str`
        *   **Default:** `"0666"`
        *   **Description:** Permissions mask for created files (octal). Only relevant for Samba.
    *   **`directoryMask`**:
        *   **Type:** `types.str`
        *   **Default:** `"0777"`
        *   **Description:** Permissions mask for created directories (octal). Only relevant for Samba.
    *   **`enableNFS`**:
        *   **Type:** `types.bool`
        *   **Default:** `false`
        *   **Description:** Also export this share via NFS.
    *   **`nfsOptions`**:
        *   **Type:** `types.listOf types.str`
        *   **Default:** `[ "rw" "sync" "no_subtree_check" ]`
        *   **Description:** NFS export options.
    *   **`nfsClients`**:
        *   **Type:** `types.str`
        *   **Default:** `"192.168.0.0/16"`
        *   **Example:** `"192.168.1.0/24"`
        *   **Description:** Network range for NFS access (CIDR notation).

