# gitea

This Nix module provides a convenient way to deploy and configure a Gitea Git service. Gitea is a self-hosted Git management solution, offering features like repository hosting, issue tracking, and code review. This module simplifies the setup and configuration of Gitea within a NixOS environment, allowing you to quickly get a self-hosted Git service up and running. It handles basic configuration options and integrates with NixOS services and firewall management.

## Options

Here's a detailed breakdown of the available configuration options within the `local.gitea` namespace:

### `local.gitea.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the Gitea Git service. When set to `true`, this option activates the Gitea service and configures it according to the other options in this module.

### `local.gitea.port`

*   **Type:** `types.port`
*   **Default:** `3001`
*   **Description:** Specifies the HTTP port that the Gitea web interface will listen on. This is the port you will use to access Gitea in your web browser.

### `local.gitea.sshPort`

*   **Type:** `types.port`
*   **Default:** `2222`
*   **Description:** Defines the SSH port used for Git operations (e.g., `git clone`, `git push`, `git pull`).  Make sure this port is not already in use by another service.

### `local.gitea.domain`

*   **Type:** `types.str`
*   **Default:** `"localhost"`
*   **Example:** `"git.example.com"`
*   **Description:** Sets the domain name for the Gitea instance. This is crucial for configuring Gitea to work correctly with your network and DNS settings. If you're using a reverse proxy, ensure this matches the domain the proxy is configured for.

### `local.gitea.rootUrl`

*   **Type:** `types.str`
*   **Default:** `"http://localhost:3001/"` (dynamically constructed using `cfg.port`)
*   **Example:** `"https://git.example.com/"`
*   **Description:**  Determines the root URL for the Gitea instance. This URL is used internally by Gitea for generating links and redirects.  Pay close attention to including the trailing slash (`/`) and ensuring the protocol (HTTP or HTTPS) is correct, especially if using a reverse proxy with SSL termination.

### `local.gitea.dataDir`

*   **Type:** `types.str`
*   **Default:** `"/var/lib/gitea"`
*   **Description:**  Specifies the directory where Gitea stores its data, including the SQLite database (if used), repositories, and configuration files.  Ensure this directory exists and is writable by the Gitea service user.  Consider backing up this directory regularly to protect your Gitea data.

### `local.gitea.openFirewall`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:**  When set to `true`, this option automatically opens the HTTP port (`local.gitea.port`) and the SSH port (`local.gitea.sshPort`) in the NixOS firewall, allowing external access to the Gitea instance.  Only enable this option if you are not using a separate firewall management system or have already configured the firewall manually.  If you're using a reverse proxy, you might not need to open the SSH port.

