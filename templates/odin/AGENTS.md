# Agent Guidelines for Odin Projects

This is an Odin project template.

## Tools
- `odin`: The Odin compiler
- `ols`: Odin Language Server

## Commands
- `just build`: Compile the project to `bin/main`
- `just run`: Run the compiled binary
- `just check`: Check the code for errors

## ❄️ Nix Rules & Conventions
- **Hard Rule**: If you need a quick script or to run a command, you MUST use Nix.
- Everything permanent should be defined in the `flake.nix`. **Keep it clean and simple.**
- Any extra or complex Nix files should be placed in a dedicated `nix/` subfolder.
