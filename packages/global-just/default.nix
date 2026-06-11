{ pkgs, ... }:

let
  globalJustfile = pkgs.writeText "global-justfile" ''
    # Global Justfile - Fallback when no local justfile is present

    default:
        @just --list

    # --- Git & Workspace ---
    [group('git')]
    sync msg="auto update":
        git add -A
        git commit -m "{{msg}}" || true
        git push

    [group('git')]
    gmc:
        git add -A
        gmc --auto
        git push

    # --- Nix ---
    [group('nix')]
    update:
        nix flake update

    [group('nix')]
    run-dot:
        nix run .

    # --- Flutter ---
    [group('flutter')]
    fr:
        flutter run

    [group('flutter')]
    fi:
        flutter install

    [group('flutter')]
    bapk:
        flutter build apk

    # --- System & Storage ---
    [group('sys')]
    mount dev tgt:
        sudo mount /dev/{{dev}} {{tgt}}

    [group('sys')]
    umount tgt:
        sudo umount {{tgt}}

    # --- NixOS Compose (nxc) ---
    [group('nxc')]
    nxc-up:
        nxc up

    [group('nxc')]
    nxc-shell node="clt":
        nxc shell {{node}}
        
    [group('nxc')]
    nxc-mon:
        nxc-monitor

    # --- Project Setup ---
    [group('new')]
    new-rust-bevy dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#rust-bevy
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-esp32-rust dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#esp32-rust
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-odin dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#odin
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-flutter dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#flutter
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-nixos-compose dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#nixos-compose
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-rust-cli dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#rust-cli
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-platformio dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#platformio
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-rocket-forge dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#rocket-forge
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-python-uv dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#python-uv
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-python-rust-uv dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#python-rust-uv
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-system-module dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#system-module
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-home-module dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#home-module
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-system-config dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#system-config
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"

    [group('new')]
    new-home-config dir:
        mkdir -p {{dir}}
        cd {{dir}} && nix flake init -t ~/.dotfiles.nix#home-config
        cd {{dir}} && git init && git add .
        cd {{dir}} && nix build . || true
        cd {{dir}} && git commit -m "init commit"
  '';
in
pkgs.writeShellApplication {
  name = "j";
  runtimeInputs = [ pkgs.just ];
  text = ''
    if [ -f justfile ] || [ -f Justfile ] || [ -f .justfile ]; then
      exec just "$@"
    else
      exec just -f "${globalJustfile}" -d "$PWD" "$@"
    fi
  '';
}
