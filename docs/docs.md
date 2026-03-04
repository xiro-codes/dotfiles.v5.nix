# Dotfiles Documentation Module

This Nix module provides a service for serving documentation generated from your dotfiles. It uses Caddy as a simple and efficient web server to host the documentation files.

## Options

### `local.docs.enable`

Type: `boolean`

Default: `false`

Description: Enables the dotfiles documentation service.  When enabled, a systemd service will be created to serve the documentation.  This is the main switch to turn the documentation service on or off.

### `local.docs.port`

Type: `port` (integer between 1 and 65535)

Default: `3088`

Description:  The port on which the documentation service will listen for incoming HTTP requests.  Choose a port that is not already in use by another service on your system. Ensure your firewall allows traffic on this port if you intend to access the documentation from outside your local machine.

### `local.docs.package`

Type: `package`

Default:  `inputs.self.packages.x86_64-linux.docs-site` (typically a derivation representing the built documentation website)

Description:  The Nix package containing the static website files for your documentation.  This package should contain an `index.html` file at the root, or Caddy may need further configuration to serve correctly. The default value points to a package named `docs-site` defined within the `packages` output of your Nix flake (often generated from a documentation build process). You can override this if your documentation is built differently or if you want to use pre-built documentation.
