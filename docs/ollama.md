# ollama

This module provides configuration options to easily set up and manage Ollama, a tool for running large language models locally, along with an optional web UI. It allows enabling Ollama with Vulkan support and configuring a separate web UI for interacting with Ollama models.

## Options

### `local.ai.webui.enable`

  *   Type:  Boolean
  *   Default: `false`
  *   Description:  Enables the Open WebUI service. This provides a web interface for interacting with the Ollama server and managing models.

### `local.ai.webui.port`

  *   Type:  Port (Integer between 1 and 65535)
  *   Default: `8080`
  *   Description:  The HTTP port that the Open WebUI service will listen on.  This determines the port you will use in your web browser to access the WebUI (e.g., `http://localhost:8080`).

### `local.ai.ollama.enable`

  *   Type:  Boolean
  *   Default: `false`
  *   Description:  Enables the Ollama service with Vulkan support.  This sets up the Ollama server to run models using the Vulkan API for GPU acceleration.

### `local.ai.ollama.port`

  *   Type:  Port (Integer between 1 and 65535)
  *   Default: `11434`
  *   Description:  The HTTP port that the Ollama service will listen on. This is the port used by clients (including the web UI) to communicate with the Ollama server.

## Details and Functionality

This module streamlines the setup of Ollama and Open WebUI within a NixOS environment.  It handles service configuration, firewall rules, and environment variable settings.

*   **Web UI Configuration (`local.ai.webui`):**
    *   Enabling `local.ai.webui.enable` activates the `services.open-webui` service.
    *   The `port` option configures the port the web UI listens on.
    *   `openFirewall` is enabled by default, automatically opening the specified port in the firewall.
    *   Environment variables are set to disable SSL verification, which is helpful for local development and internal connections.  Specifically:
        *   `REQUESTS_VERIFY = "False"`: Disables SSL verification for the `requests` library in Python.
        *   `AIOHTTP_CLIENT_SESSION_SSL = "False"`:  Disables SSL verification for `aiohttp`, used for internal connections within the WebUI.
        *   `AIOHTTP_CLIENT_SESSION_TOOL_SERVER_SSL = "False"`: Disables SSL verification when connecting to a tool server if one is configured
        *   `ENABLE_PERSISTENT_CONFIG = "False"`:  Forces Open WebUI to reload its configuration from the Nix configuration on every boot, preventing cached settings from interfering.  This is *highly* recommended for reproducibility.

*   **Ollama Configuration (`local.ai.ollama`):**
    *   Enabling `local.ai.ollama.enable` activates the `services.ollama` service.
    *   The `port` option configures the port the Ollama server listens on.
    *   `openFirewall` is enabled by default, opening the specified port in the firewall.
    *   `package = pkgs.ollama-vulkan`:  Specifies the Ollama package to use, ensuring it's built with Vulkan support for GPU acceleration.
    *   `host = "0.0.0.0"`:  Binds the Ollama server to all network interfaces, making it accessible from other devices on the network.
    *   `syncModels = true`: Enables automatic syncing of models.
    *   `loadModels = [ "qwen3" ]`:  Specifies a list of models to automatically load when the Ollama service starts.  In this example, "qwen3" is automatically loaded.  You can add more models to this list.
    *   `hardware.graphics.enable = true`: Enables graphics hardware support, crucial for Vulkan-based GPU acceleration.  This is a necessary setting for utilizing the GPU with Ollama.

## Example Usage

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./ollama.nix  # Assuming the above module is saved as ollama.nix
  ];

  local.ai.webui = {
    enable = true;
    port = 8081; # changed from default
  };

  local.ai.ollama = {
    enable = true;
    port = 11435; # changed from default
    loadModels = [ "llama2" "qwen3" ]; # Added llama2
  };
}
```

This example enables both the web UI and Ollama services.  The web UI will listen on port 8081, and Ollama will listen on port 11435. It also ensures both `qwen3` and `llama2` models are loaded upon startup. Remember to adapt the configuration to your specific needs.
