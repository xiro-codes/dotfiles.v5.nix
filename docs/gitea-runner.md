```markdown
# gitea-runner

This module configures and enables a Gitea Actions Runner, leveraging Podman for container execution. It provides options to customize the runner's connection to a Gitea instance, its registration token, and the labels used to identify it for job assignment. It assumes podman is being used for containerisation.

## Options

### `local.gitea-runner.enable`

Type: `boolean`

Default: `false`

Description: Enables the Gitea Actions Runner. When set to `true`, the module will configure and start the runner service using Podman for container execution.

### `local.gitea-runner.instanceName`

Type: `string`

Default: `"default-runner"`

Description: The name of the runner instance. This name is used to identify the runner within the Gitea instance.  It's also used as the key in the `services.gitea-actions-runner.instances` attribute set.

### `local.gitea-runner.giteaUrl`

Type: `string`

Default: (Conditional) `http://127.0.0.1:${toString config.local.gitea.port}` if `config.local.gitea.enable` is true, otherwise `http://127.0.0.1:3001`

Description: The URL of the Gitea instance to connect to. This URL is used by the runner to register itself and receive job assignments.  It dynamically determines the URL based on whether the `local.gitea` module is enabled. If `local.gitea` is enabled, it uses port from gitea module config otherwise defaults to port 3001.

### `local.gitea-runner.tokenFile`

Type: `string`

Default: `"/run/secrets/gitea/runner_token"`

Description: The path to the file containing the runner registration token. This token is required for the runner to authenticate with the Gitea instance.  It's assumed that a sops secret exists at this path by default.  This path can be overridden to point to a different location.

### `local.gitea-runner.labels`

Type: `list of strings`

Default:
```nix
[
  "ubuntu-latest:docker://node:18-bullseye"
  "ubuntu-22.04:docker://node:18-bullseye"
  "ubuntu-20.04:docker://node:16-bullseye"
  "nixos-latest:docker://nixos/nix:latest"
]
```

Description: A list of labels for the runner. These labels are used to match the runner with jobs that require specific environments or capabilities.  The format `ubuntu-latest:docker://node:18-bullseye` indicates that the label is `ubuntu-latest` and the container image to use for the job is `docker://node:18-bullseye`.
```
