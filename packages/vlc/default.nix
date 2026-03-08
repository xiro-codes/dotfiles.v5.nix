{ pkgs, lib, ... }:
let
  libbluray' = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
  };
in
pkgs.vlc.override { libbluray = libbluray'; }
