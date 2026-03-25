{ pkgs, inputs, ... }:

pkgs.writeShellScriptBin "serve-docs" ''
  # Clean up any previous mdbook processes
  pkill mdbook || true
  
  # Create a temp dir for the book to combine manual + generated docs
  BOOK_DIR=$(mktemp -d)
  
  # Set up the book source directory
  mkdir -p $BOOK_DIR/src
  
  # Clean up on exit
  trap "rm -rf $BOOK_DIR" EXIT
  
  # Use the flake's root path for robustness
  FLAKE_ROOT="${inputs.self}"
  
  # Check if the flake root is a git repository with a work tree
  # If so, we can use the local files for live reloading
  if [ -d "$FLAKE_ROOT/.git" ] && [ -n "$(git -C "$FLAKE_ROOT" rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
    echo "Live reloading enabled. Using local files from $FLAKE_ROOT"
    DOC_SRC="$FLAKE_ROOT/docs"
    README_SRC="$FLAKE_ROOT/README.md"
  else
    echo "Live reloading disabled. Using read-only files from the Nix store."
    DOC_SRC="${inputs.self}/docs"
    README_SRC="${inputs.self}/README.md"
  fi
  
  if [ ! -d "$DOC_SRC" ]; then
     echo "Error: 'docs' directory not found at $DOC_SRC."
     exit 1
  fi
  
  echo "Preparing documentation in $BOOK_DIR..."
  
  # Copy the book config
  cp "$DOC_SRC/book.toml" "$BOOK_DIR/"
  
  # Symlink docs to allow live reloading of manual edits, using README.md as intro
  rm -f "$BOOK_DIR/src/modules.md" "$BOOK_DIR/src/system-modules.md" "$BOOK_DIR/src/home-modules.md"
  ln -s "$DOC_SRC"/* "$BOOK_DIR/src/"
  # Remove the book config from the src dir to avoid mdbook confusion
  rm "$BOOK_DIR/src/book.toml"
  ln -s "$README_SRC" "$BOOK_DIR/src/intro.md"
  
  # Link generated docs from the nix store (these won't live reload unless rebuilt)
  ln -s "${inputs.self.packages.x86_64-linux.docs-generated}/README.md" "$BOOK_DIR/src/modules.md"
  ln -s "${inputs.self.packages.x86_64-linux.docs-generated}/system-modules.md" "$BOOK_DIR/src/system-modules.md"
  ln -s "${inputs.self.packages.x86_64-linux.docs-generated}/home-modules.md" "$BOOK_DIR/src/home-modules.md"
  
  echo "Serving docs at http://localhost:3000 (usually)..."
  ${pkgs.mdbook}/bin/mdbook serve "$BOOK_DIR" --open
''
