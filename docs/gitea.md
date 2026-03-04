# gitea

This module provides a Nix configuration for deploying a Gitea Git service. Gitea is a self-hosted Git management software. It includes options for configuring the HTTP and SSH ports, domain, root URL, data directory, and firewall settings. It also configures the Gitea service with sensible defaults and enables it if specified.

## Options

Here's a detailed list of the available options and their configurations:

### `local.gitea.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:** Enables or disables the Gitea Git service. Setting this option to `true` will configure and enable the Gitea service.

### `local.gitea.port`

*   **Type:** `port` (integer representing a port number)
*   **Default:** `3001`
*   **Description:** The HTTP port for the Gitea web interface. This is the port that users will use to access Gitea through a web browser.

### `local.gitea.sshPort`

*   **Type:** `port` (integer representing a port number)
*   **Default:** `2222`
*   **Description:** The SSH port for Git operations. This port is used for cloning, pushing, and pulling Git repositories via SSH.

### `local.gitea.domain`

*   **Type:** `string`
*   **Default:** `"localhost"`
*   **Example:** `"git.example.com"`
*   **Description:** The domain name for the Gitea instance. This should be a valid domain name or subdomain that resolves to the server running Gitea.

### `local.gitea.rootUrl`

*   **Type:** `string`
*   **Default:** `"http://localhost:3001/"`
*   **Example:** `"https://git.example.com/"`
*   **Description:** The root URL for accessing Gitea. This URL is used by Gitea to generate links and redirects.  It *must* end with a trailing slash.  If you are using HTTPS, be sure to specify `https://` here.

### `local.gitea.dataDir`

*   **Type:** `string`
*   **Default:** `"/var/lib/gitea"`
*   **Description:** The data directory for Gitea. This directory stores the Gitea database, repositories, and other data. Make sure this directory is writable by the Gitea user.

### `local.gitea.openFirewall`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**  Opens the firewall ports for Gitea, specifically the HTTP port (`local.gitea.port`) and SSH port (`local.gitea.sshPort`).  Setting this to true will automatically configure the NixOS firewall to allow traffic on these ports.

## Configuration Details

When `local.gitea.enable` is set to `true`, the following configurations are applied:

*   The `services.gitea.enable` option is set to `true`, enabling the Gitea service.
*   The `services.gitea.appName` is set to `"Gitea: Git with a cup of tea"`.
*   The database type is set to `sqlite3` and the path is set to `${cfg.dataDir}/data/gitea.db`.
*   The `settings.server.DOMAIN` is set to the calculated domain.
*   The `settings.server.ROOT_URL` is set to the calculated root URL.
*   The `settings.server.HTTP_PORT` is set to the value of `local.gitea.port`.
*   The `settings.server.SSH_PORT` is set to the value of `local.gitea.sshPort`.
*   The `settings.server.START_SSH_SERVER` is set to `true`.
*   Various settings for `service`, `session`, `repository`, `ui`, and `actions` are configured with reasonable defaults.
*   The `services.gitea.stateDir` is set to the value of `local.gitea.dataDir`.
*   If `local.gitea.openFirewall` is set to `true`, the `networking.firewall.allowedTCPPorts` option is configured to allow traffic on the HTTP and SSH ports.

