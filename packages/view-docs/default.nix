{
  pkgs,
  inputs,
  self,
  ...
}:
pkgs.writeShellScriptBin "view-docs" ''
  ${pkgs.glow}/bin/glow ${self.packages.x86_64-linux.docs-generated}/README.md
''
