{
  pkgs,
  inputs,
  self,
  ...
}:
let
  system = "x86_64-linux";
in
pkgs.runCommand "dotfiles-docs-site"
  {
    nativeBuildInputs = [
      pkgs.mdbook
      pkgs.graphviz
      pkgs.python3
      self.packages.${system}.docs-generated
    ];
  }
  ''
    # Setup build directory structure
    mkdir -p tmp_book/src

    # Copy manual docs
    cp -r ${../../docs}/* tmp_book/src/
    chmod -R +w tmp_book/src

    # Copy generated docs
    cp -r ${self.packages.${system}.docs-generated}/* tmp_book/src/

    # Append generated options to handwritten docs
    cat << 'EOF' > merge.py
import os
import sys

src_dir = sys.argv[1]
gen_dirs = ["system", "home"]

for gd in gen_dirs:
    gen_path = os.path.join(src_dir, gd)
    if not os.path.exists(gen_path): continue
    for f in os.listdir(gen_path):
        if f.endswith(".md"):
            mod_name = f
            src_md = os.path.join(src_dir, mod_name)
            if os.path.exists(src_md):
                with open(src_md, "a") as out:
                    with open(os.path.join(gen_path, f), "r") as inf:
                        # Append the options
                        # We only append if there isn't already a generated options section
                        out.write("\n\n## Generated Options\n\n")
                        out.write(inf.read())
EOF
    python3 merge.py tmp_book/src

    # Setup book.toml at the root of the book directory
    cp tmp_book/src/book.toml tmp_book/

    # Setup intro page
    cp ${../../README.md} tmp_book/src/intro.md

    # Build the book to $out
    mdbook build -d $out tmp_book
  ''
