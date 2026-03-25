{ pkgs, inputs, ... }:

pkgs.writeShellScriptBin "view-docs" ''
  ${pkgs.glow}/bin/glow ${inputs.self.packages.x86_64-linux.docs-generated}/README.md
''
