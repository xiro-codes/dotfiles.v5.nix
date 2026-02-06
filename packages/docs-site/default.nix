{ pkgs, inputs, ... }:

pkgs.runCommand "dotfiles-docs-site"
{
  nativeBuildInputs = [ pkgs.mdbook inputs.self.packages.${pkgs.system}.docs-generated ];
} ''
  mkdir -p $out/src
  
  # Copy manual docs, but use README.md for the intro page
  cp -r ${../../docs}/* $out/src/
  mv $out/src/book.toml $out/ || true
  cp ${../../README.md} $out/src/intro.md
  
  
  cp -r ${inputs.self.packages.${pkgs.system}.docs-generated}/* $out/src/
  
  # Build
  mdbook build -d $out/ $out
''
