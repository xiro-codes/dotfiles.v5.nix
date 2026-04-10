# Dotfiles Documentation Module

This Nix module provides a way to serve documentation for your dotfiles using Caddy. It sets up a systemd service that serves the documentation package on a specified port.

## Options

### `local.docs.enable`

Type: Boolean

Default: `false`

Description: Enables the dotfiles documentation service. When enabled, a systemd service will be created to serve the documentation.

### `local.docs.port`

Type: Port (Integer between 1 and 65535)

Default: `3088`

Description: The port on which the documentation service will listen for connections.  This determines the port number that will be used to access the documentation in a web browser (e.g., `http://localhost:3088`).

### `local.docs.package`

Type: Package

Default: `inputs.self.packages.x86_64-linux.docs-site`

Description: The Nix package containing the documentation files to be served. This option allows you to specify the exact location of your documentation.  The default value assumes that your documentation is built as a package named `docs-site` within your project's `packages` attribute set for the `x86_64-linux` system. Ensure that this package contains the necessary HTML, CSS, JavaScript, and other assets to correctly render your documentation.

## Details

When `local.docs.enable` is set to `true`, the module creates a systemd service named `docs`.

The service:

*   **Description:** "Dotfiles Documentation"
*   **After:** `network.target` (ensures the network is up before starting the service)
*   **WantedBy:** `multi-user.target` (starts the service when the system enters multi-user mode)

The service is configured to:

*   **ExecStart:** Executes the Caddy web server to serve the documentation files.  The command uses `caddy file-server` to serve static files from the specified root directory. The `--listen` flag specifies the address and port on which Caddy will listen. The `--root` flag specifies the root directory of the documentation files.

    *   `${pkgs.caddy}/bin/caddy`:  Specifies the path to the Caddy executable from Nix packages.
    *   `file-server`: Tells Caddy to run in file server mode, serving static files.
    *   `--listen "0.0.0.0:${toString config.local.docs.port}"`: Configures Caddy to listen on all interfaces (0.0.0.0) and the specified port.  The `toString` function is used to convert the port number to a string.
    *   `--root "${config.local.docs.package}"`:  Sets the root directory for serving the documentation files to the specified package's path.

*   **Restart:** `always` (ensures the service restarts automatically if it crashes)
*   **User:** `nobody` (runs the service as the `nobody` user for security)
*   **Group:** `nogroup` (runs the service under the `nogroup` group for security)

This setup allows you to easily access your dotfiles documentation in a web browser on your local machine or network, making it convenient to reference and share.
