# pihole

This module provides an easy way to deploy Pi-hole, a network-wide ad blocker, using Nix and OCI containers (specifically, Docker). It configures a containerized Pi-hole instance with persistent storage, sets up necessary firewall rules, and ensures that the required data directories exist.  The module aims to simplify the deployment process and integrate well within a NixOS environment. It shifts the web UI port to 8053 to avoid conflicts with other web servers potentially running on port 80 (like Nginx).

## Options

Here's a detailed breakdown of the configurable options available within the `local.pihole` namespace.

### `local.pihole.enable`

**Type:**  `boolean`

**Default:**  `false` (disabled)

**Description:**

This option is the primary switch to enable or disable the Pi-hole service. Setting it to `true` will activate the entire Pi-hole configuration defined within this module, including container deployment, firewall rules, and directory setup.  When disabled, none of the Pi-hole related components will be configured. Use this to easily turn Pi-hole on and off without removing its configuration.

### `local.pihole.dataDir`

**Type:**  `string`

**Default:**  `"/var/lib/pihole"`

**Description:**

Specifies the directory used to store Pi-hole's persistent data, including its configuration files, DNS blocklists, and other relevant data.  This directory is mounted as a volume into the Pi-hole container, ensuring that Pi-hole's data persists across container restarts and updates.  It's crucial for maintaining your Pi-hole setup. Make sure this directory is properly backed up.

It also creates a `dnsmasq.d` subdirectory within the specified `dataDir` to hold custom DNS configurations for `dnsmasq`, the DNS server used by Pi-hole.

### `local.pihole.adminPassword`

**Type:**  `string`

**Default:**  `"admin"`

**Description:**

Sets the password for the Pi-hole web administration interface. This password is used to protect the web UI and prevent unauthorized access to Pi-hole's settings.

**Important Security Note:** The default password "admin" is extremely insecure and should **always** be changed to a strong, unique password before deploying Pi-hole in a production environment. Failing to do so will expose your Pi-hole installation to potential attacks and unauthorized configuration changes.  A long, randomly generated password is highly recommended.
