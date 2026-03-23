```markdown
# ollama

This Nix module provides a convenient way to enable and configure Ollama with Vulkan support on NixOS. It automatically sets up the necessary services and hardware configurations for a seamless Ollama experience.

## Options

This module defines the following options:

### `local.ollama.enable`

*   **Type:** `types.bool`
*   **Default:** `false`
*   **Description:** Enables the Ollama Vulkan setup. When enabled, this option configures the `services.ollama` service and ensures necessary hardware graphics are enabled. Enabling also sets `services.ollama.openFirewall = true`.

## Configuration Details

When `local.ollama.enable` is set to `true`, the following configurations are applied:

*   **`services.ollama.enable`**: This option is set to `true`, enabling the `ollama` service.
*   **`services.ollama.openFirewall`**: Automatically set to `true` opening the firewall for ollama.
*   **`services.ollama.package`**: Specifies the Ollama package to use. In this case, it defaults to `pkgs.ollama-vulkan`, ensuring that the Vulkan-enabled version of Ollama is used.
*   **`hardware.graphics.enable`**: This option is set to `true`, ensuring that the necessary graphics drivers and configurations are enabled for Vulkan support. This is important for Ollama to leverage GPU acceleration.

**In Summary:** This module abstracts the complexities of setting up Ollama with Vulkan on NixOS. By simply enabling `local.ollama.enable`, you can quickly get Ollama running with proper GPU acceleration and firewall configuration.
```
