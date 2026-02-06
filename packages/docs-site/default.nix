{ pkgs, inputs, ... }:

pkgs.runCommand "dotfiles-docs-site"
{
  nativeBuildInputs = [ pkgs.mdbook ];
} ''
  mkdir -p $out/src
  
  # Copy manual docs, but use README.md for the intro page
  cp -r ${../../docs}/* $out/src/
  cp ${../../README.md} $out/src/intro.md
  
  # Copy generated docs (overwriting manual ones if they exist)
  cp ${inputs.self.packages.x86_64-linux.docs-generated}/README.md $out/src/modules.md
  cp ${inputs.self.packages.x86_64-linux.docs-generated}/system-modules.md $out/src/system-modules.md
  cp ${inputs.self.packages.x86_64-linux.docs-generated}/home-modules.md $out/src/home-modules.md
  
  # Build
  cd $out/src
  mdbook build -d $out/
''
