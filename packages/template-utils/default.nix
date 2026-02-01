{pkgs, ...}:
let 
  dotfiles-root = "$(git rev-parse --show-toplevel 2>/dev/null || echo $HOME/.dotfiles)";
  mkGen = name: templateSubPath: targetSubDir: ''
    EDIT=false
    while getopts "e" opt; do 
      case $opt in
        e) EDIT=true;;
        *) echo "Usage: ${name} [-e] <name>"; exiti 1;;
      esac 
    done
    shift $((OPTIND-1))

    NAME=$1
    if [ -z "$NAME" ]; then echo "Error: Name argument required."; exit 1; fi

    # Resolve absolute paths
    ROOT="${dotfiles-root}"
    TEMPLATE="$ROOT/${templateSubPath}"
    TARGET_DIR="$ROOT/${targetSubDir}"
    TARGET="$TARGET_DIR/$NAME"

    if [ ! -d "$ROOT" ]; then echo "Error: Could not find dotfiles root."; exit 1; fi
    if [ -d "$TARGET" ]; then echo "Error: $TARGET already exists."; exit 1; fi

    mkdir -p "$TARGET"
    cp -r "$TEMPLATE"/* "$TARGET/"
    chmod -R u+w "$TARGET"
    
    # Run git add from the root context
    (cd "$ROOT" && git add "$TARGET")
    
    echo "Generated $NAME in $TARGET"
    
    if [ "$EDIT" = true ]; then
      $EDITOR "$TARGET/default.nix" || $EDITOR "$TARGET/configuration.nix"
    fi
  '';
in pkgs.symlinkJoin {
  name = "template-utils";
  paths  = with pkgs; [
    (writeShellScriptBin "gen-sys-module" (mkGen "gen-sys-module" "templates/system-module" "modules/system")) 
    (writeShellScriptBin "gen-home-module" (mkGen "gen-sys-module" "templates/home-module" "modules/home")) 
    (writeShellScriptBin "gen-system" (mkGen "gen-system" "templates/system-config" "systems")) 
    (writeShellScriptBin "gen-home" (mkGen "gen-home" "templates/home-config" "home")) 
    (writeShellScriptBin "gen-pkg" ''
      if [ -z "$1" ]; then echo "Usage: gen-pkg <url>"; exit 1; fi
      ROOT="${dotfiles-root}"
      NAME=$(basename "$1")
      ${lib.getExe pkgs.nix-init} -o "$ROOT/packages/$NAME" "$1"
      (cd "$ROOT" && git add "packages/$NAME")
    '')


  ];

}
