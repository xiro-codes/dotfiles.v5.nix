# file-browser

This module provides a web-based file browser accessible through a web interface. It leverages the `filebrowser` service in Nixpkgs and allows you to configure various aspects such as the port it runs on, the root directory it serves, and firewall rules. This module simplifies the deployment and management of a basic file browser, making it easy to share files on your network.

## Options

This module defines the following options under the `local.file-browser` namespace:

### `local.file-browser.enable`

Type: `boolean`

Default: `false`

Description: Enables or disables the web-based file browser. When enabled, the `filebrowser` service is configured based on other options. This is the primary switch to activate the module's functionality.

### `local.file-browser.port`

Type: `port` (Integer between 1 and 65535)

Default: `8999`

Description: The port on which the web interface will be accessible.  It's crucial to select an available port and configure any relevant firewalls accordingly. Changing this might be necessary if the default port is already in use by another service.

### `local.file-browser.openFirewall`

Type: `boolean`

Default: `false`

Description: Determines whether the firewall port for File Browser should be opened automatically.  Setting this to `true` will attempt to open the configured port in your system's firewall. Be mindful of security implications when exposing services to a network.

### `local.file-browser.rootPath`

Type: `string`

Default: `"/media"`

Description: The root path from which files will be served.  This specifies the directory that will be the base directory for browsing files. It is important to set this to a directory with the files that you would like to browse, such as `/media`, `/home`, or another custom path. Make sure the filebrowser process has the necessary permissions to read this directory and its contents.
