# file-sharing

This Nix module provides a comprehensive solution for setting up file sharing services on your NixOS system.  It supports both Samba and NFS, allowing you to easily share files with other devices on your network.  It simplifies configuration by allowing you to define shares in a structured way, and automatically generates the necessary configurations for both Samba and NFS based on these definitions.  It also handles firewall rules and directory creation.

## Options

Here's a breakdown of the options available in this module:

### `local.file-sharing.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the file sharing services module.  This is the main switch to control whether the file sharing components are activated.

### `local.file-sharing.shareDir`

*   **Type:** `string`
*   **Default:** `"/srv/shares"`
*   **Example:** `"/mnt/storage/shares"`
*   **Description:**  Specifies the base directory where shared files will be located.  This directory will be created (if it doesn't exist) and is the root for shares defined under `definitions`.  It's good practice to set this to a dedicated mount point for your shared storage.

### `local.file-sharing.nfs.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the NFS server. If set to `true`, the NFS server will be configured and started.

### `local.file-sharing.nfs.exports`

*   **Type:** `lines` (string containing multiple lines)
*   **Default:** `""`
*   **Example:**

    ```nix
    ''
      /srv/shares 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      /srv/media 192.168.1.0/24(ro,sync,no_subtree_check)
    ''
    ```

*   **Description:**  Defines the NFS exports configuration.  This option allows you to specify NFS exports using the standard NFS exports file syntax.  Each line represents an export, specifying the directory to share and the clients that are allowed to access it, along with their access options.  These are combined with exports from structured definitions.

### `local.file-sharing.nfs.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the necessary firewall ports for NFS.  If set to `true`, the module will automatically configure the firewall to allow NFS traffic.

### `local.file-sharing.samba.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables the Samba server.  If set to `true`, the Samba server will be configured and started.

### `local.file-sharing.samba.workgroup`

*   **Type:** `string`
*   **Default:** `"WORKGROUP"`
*   **Description:** Specifies the Samba workgroup name.  This should match the workgroup used by other devices on your network.

### `local.file-sharing.samba.serverString`

*   **Type:** `string`
*   **Default:** `"NixOS File Server"`
*   **Description:** Specifies the server description string that will be displayed in network browsing lists.

### `local.file-sharing.samba.shares`

*   **Type:** `attribute set of attribute sets`
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

*   **Description:** Defines Samba share definitions using the raw Samba configuration format.  This is useful for advanced configurations or features not covered by the `definitions` option.  These shares are merged with those defined under the `definitions` option.  Each attribute name represents a share name, and its value is another attribute set specifying the share's configuration options.
    *   **`path`**: (string) -  The path to the directory to be shared.
    *   **`read only`**: (string, "yes" or "no") - Whether the share is read-only.
    *   **`browseable`**: (string, "yes" or "no") - Whether the share is browseable.
    *   **`guest ok`**: (string, "yes" or "no") - Whether guest access is allowed.

### `local.file-sharing.samba.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Opens the necessary firewall ports for Samba.  If set to `true`, the module will automatically configure the firewall to allow Samba traffic.

### `local.file-sharing.definitions`

*   **Type:** `attribute set of submodules`
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

*   **Description:** Defines structured share definitions that automatically configure both Samba and NFS. This is the preferred way to define shares, as it provides a consistent and simplified interface for both protocols. Each attribute name represents a share name, and its value is a submodule with the following options:

    *   **`path`**:
        *   **Type:** `path`
        *   **Description:** Absolute path to the share directory.

    *   **`comment`**:
        *   **Type:** `string`
        *   **Default:** `""`
        *   **Description:** Description of the share. This comment is used by both Samba and NFS.

    *   **`readOnly`**:
        *   **Type:** `boolean`
        *   **Default:** `false`
        *   **Description:** Whether the share is read-only.

    *   **`guestOk`**:
        *   **Type:** `boolean`
        *   **Default:** `false`
        *   **Description:** Allow guest access without authentication.

    *   **`browseable`**:
        *   **Type:** `boolean`
        *   **Default:** `true`
        *   **Description:** Whether the share is visible in browse lists.

    *   **`validUsers`**:
        *   **Type:** `list of strings`
        *   **Default:** `[]`
        *   **Example:** `[ "alice" "bob" ]`
        *   **Description:** List of users allowed to access the share.  An empty list means all users are allowed.  This option only applies to Samba.

    *   **`writeable`**:
        *   **Type:** `boolean`
        *   **Default:** `true`
        *   **Description:** Whether users can write to the share.  Implied false if `readOnly` is true. This option applies to Samba only.

    *   **`createMask`**:
        *   **Type:** `string`
        *   **Default:** `"0666"`
        *   **Description:** Permissions mask for created files (Samba only).

    *   **`directoryMask`**:
        *   **Type:** `string`
        *   **Default:** `"0777"`
        *   **Description:** Permissions mask for created directories (Samba only).

    *   **`enableNFS`**:
        *   **Type:** `boolean`
        *   **Default:** `false`
        *   **Description:** Also export this share via NFS.

    *   **`nfsOptions`**:
        *   **Type:** `list of strings`
        *   **Default:** `[ "rw" "sync" "no_subtree_check" ]`
        *   **Description:** NFS export options.  These options are passed directly to the NFS exports file.

    *   **`nfsClients`**:
        *   **Type:** `string`
        *   **Default:** `"192.168.0.0/16"`
        *   **Example:** `"192.168.1.0/24"`
        *   **Description:** Network range for NFS access. This specifies which clients are allowed to access the NFS share.
