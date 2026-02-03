{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "hyprland-workspace-tools";
  version = "1.0.0";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin

    # hypr-workspace-set: Navigate to workspace in current set
    cat > $out/bin/hypr-workspace-set << 'EOF'
#!/usr/bin/env bash
# Get current workspace
current=$(hyprctl activeworkspace -j | jq -r '.id')

# Determine current set (1-3 or 4-6)
if [ $current -ge 1 ] && [ $current -le 3 ]; then
  current_set=0
elif [ $current -ge 4 ] && [ $current -le 6 ]; then
  current_set=3
else
  # Default to set 1-3 for any other workspace
  current_set=0
fi

# Calculate target workspace based on action
case "$1" in
  u) offset=1 ;;
  i) offset=2 ;;
  o) offset=3 ;;
  *) exit 1 ;;
esac

target=$((current_set + offset))
hyprctl dispatch workspace $target
EOF

    # hypr-move-to-set: Move window to workspace in current set
    cat > $out/bin/hypr-move-to-set << 'EOF'
#!/usr/bin/env bash
# Get current workspace
current=$(hyprctl activeworkspace -j | jq -r '.id')

# Determine current set
if [ $current -ge 1 ] && [ $current -le 3 ]; then
  current_set=0
elif [ $current -ge 4 ] && [ $current -le 6 ]; then
  current_set=3
else
  current_set=0
fi

# Calculate target workspace for move based on action
case "$1" in
  u) offset=1 ;;
  i) offset=2 ;;
  o) offset=3 ;;
  *) exit 1 ;;
esac

target=$((current_set + offset))
hyprctl dispatch movetoworkspace $target
EOF

    # hypr-switch-set: Switch between workspace sets
    cat > $out/bin/hypr-switch-set << 'EOF'
#!/usr/bin/env bash
# Get current workspace
current=$(hyprctl activeworkspace -j | jq -r '.id')

# Determine current set and switch
if [ $current -ge 1 ] && [ $current -le 3 ]; then
  # Switch to set 4-6
  case "$1" in
    next) target=$((current + 3)) ;;
    prev) target=$current ;;  # Already in first set
    *) exit 1 ;;
  esac
elif [ $current -ge 4 ] && [ $current -le 6 ]; then
  # Switch to set 1-3
  case "$1" in
    next) target=$((current - 3)) ;;  # Back to first set
    prev) target=$((current - 3)) ;;
    *) exit 1 ;;
  esac
else
  # Default to workspace 1 for any other workspace
  target=1
fi

hyprctl dispatch workspace $target
EOF

    chmod +x $out/bin/*
  '';

  meta = with pkgs.lib; {
    description = "Workspace management tools for Hyprland with dynamic set switching";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
