## ❄️ Nix Rules & Conventions
- **Hard Rule**: If you need a quick script or to run a command, you MUST use Nix.
- Everything permanent should be defined in the `flake.nix`. **Keep it clean and simple.**
- Any extra or complex Nix files should be placed in a dedicated `nix/` subfolder.