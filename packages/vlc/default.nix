{ pkgs, input, lib }: with pkgs; let
  libbluray = libbluray.override {
    withAACS = true;
    withBDplus = true;
  };
in
vlc.override { inherit libbluray; }
