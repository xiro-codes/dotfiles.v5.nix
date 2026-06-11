{
  pkgs,
  lib,
  repoPath ? "/etc/nixos",
  ...
}:
let
  inherit (lib) getExe;
in
pkgs.writeShellApplication {
  name = "git-pull-sync";
  text = ''
    cd ${repoPath}

    # Check if the directory is a git repo
    if [ ! -d .git ]; then
      echo "Not a git repository: ${repoPath}"
      exit 0
    fi

    # Check for uncommitted changes
    if ! ${getExe pkgs.git} diff-index --quiet HEAD --; then
      echo "Local changes detected in ${repoPath}. Skipping auto-pull to avoid conflicts."
      exit 0
    fi

    echo "No local changes. Attempting to pull from remote origin..."
    ${getExe pkgs.git} pull origin main || ${getExe pkgs.git} pull origin master
  '';
}
