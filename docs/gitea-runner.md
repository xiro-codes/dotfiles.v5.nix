# gitea-runner

This module provides a way to deploy and configure a Gitea Actions Runner on a NixOS system.  It simplifies the setup by managing the runner service and its connection to a Gitea instance, leveraging Podman for container execution.  It handles token management through a file, supports customization of runner labels, and configures the runner service itself.

## Options

Here's a detailed breakdown of the available configuration options:

### `local.gitea-runner.enable`

*   **Type:** `boolean`
*   **Default:** `false`
*   **Description:**  Enables or disables the Gitea Actions Runner module. When set to `true`, the runner service will be configured and started.

### `local.gitea-runner.instanceName`

*   **Type:** `string`
*   **Default:** `"default-runner"`
*   **Description:**  The name of the runner instance. This name is used to identify the runner within Gitea and also to name the systemd service.  It's generally a good idea to use a descriptive name.

### `local.gitea-runner.giteaUrl`

*   **Type:** `string`
*   **Default:**  `"http://127.0.0.1:${toString giteaCfg.port}"` (if `local.gitea.enable` is true) or `"http://127.0.0.1:3001"` (if `local.gitea.enable` is false)
*   **Description:** The URL of the Gitea instance that the runner should connect to. This URL must be accessible from the runner. The default value dynamically uses the configured port from the `local.gitea` module if it is enabled, otherwise it falls back to a common Gitea port.  Important to note that the port number is cast to a string for string interpolation within nix.

### `local.gitea-runner.tokenFile`

*   **Type:** `string`
*   **Default:** `"/run/secrets/gitea/runner_token"`
*   **Description:** The path to the file containing the Gitea runner registration token.  This token is used to authenticate the runner with the Gitea instance. It is highly recommended to store the token in a secure location such as `/run/secrets` and manage it with sops.  The runner will read the token from this file during startup.

### `local.gitea-runner.labels`

*   **Type:** `list of strings`
*   **Default:**
    ```nix
    [
      "ubuntu-latest:docker://node:18-bullseye"
      "ubuntu-22.04:docker://node:18-bullseye"
      "ubuntu-20.04:docker://node:16-bullseye"
      "nixos-latest:docker://nixos/nix:latest"
    ]
    ```
*   **Description:**  A list of labels that define the capabilities and environment of the runner. These labels are used by Gitea to determine which runner is suitable for a given job. The format `label:docker://image` specifies a docker image to use for the execution environment. These labels are critical for directing jobs to the appropriate runner.
