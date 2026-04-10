# file-browser

This Nix module provides a web-based file browser interface. It allows you to easily browse files on your server through a convenient web interface. The module configures a `filebrowser` service with customizable options, enabling easy access to your files via a web browser. It's designed to be simple to set up and use, offering a user-friendly way to manage files remotely.

## Options

This module exposes the following options under the `local.file-browser` namespace:

### `enable`

```
Type: boolean
Default: false
```

Enables or disables the web-based file browser service. When set to `true`, the module configures and starts the `filebrowser` service using specified settings.  Setting to `false` disables the service entirely, ensuring no resources are allocated for it.

### `port`

```
Type: port (Integer between 1 and 65535 inclusive)
Default: 8999
```

Specifies the port on which the web interface will be accessible.  A `port` type ensures the value is a valid port number. Choose an unused port to avoid conflicts with other services. Changing this option requires restarting the service.

### `openFirewall`

```
Type: boolean
Default: false
```

Determines whether the firewall port for the file browser should be opened. If set to `true`, the module attempts to open the specified port via the firewall configuration, allowing external access to the web interface.  Setting to `false` keeps the port closed, restricting access to the local machine.  Ensure your system's firewall is properly configured to handle these requests.

### `rootPath`

```
Type: string
Default: "/media"
```

Defines the root path from which the file browser will serve files. This directory will be the top-level directory visible in the web interface.  It's crucial to set this to a directory containing the files you wish to access. Ensure the `filebrowser` process has appropriate permissions to read files from this directory. For example, if you want to serve files from `/mnt/data`, you would set this option to `/mnt/data`.

```
```
