{ pkgs, inputs, ... }:
let
  system = "x86_64-linux";
in

pkgs.runCommand "dotfiles-docs-site"
{
  nativeBuildInputs = [ pkgs.mdbook inputs.self.packages.${system}.docs-generated ];
} ''
  # Setup build directory structure
  mkdir -p tmp_book/src
  
  # Copy manual docs
  cp -r ${../../docs}/* tmp_book/src/
  chmod -R +w tmp_book/src
  
  # Copy generated docs
  cp -r ${inputs.self.packages.${system}.docs-generated}/* tmp_book/src/
  
  # Setup book.toml at the root of the book directory
  cp tmp_book/src/book.toml tmp_book/
  
  # Setup intro page
  cp ${../../README.md} tmp_book/src/intro.md
  
  # Build the book to $out
  mdbook build -d $out tmp_book
''
