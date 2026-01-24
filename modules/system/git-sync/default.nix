{ config, lib, pkgs, ... }:

let
  # The enhanced AI commit script with preview logic
  tgptWrapped = pkgs.writeShellScriptBin "tgpt-auth" ''
  	# Read the Gemini key from your secure local file
    if [ -f /etc/nixos/gemini-key ]; then
      export GEMINI_API_KEY=$(sudo cat /etc/nixos/gemini-key)
      # Some versions also look for GOOGLE_API_KEY
      export GOOGLE_API_KEY=$GEMINI_API_KEY
    fi

    # Call tgpt with the gemini-pro model
    # Note: --provider might vary by tgpt version; often it's 'google' or 'gemini'
    exec ${pkgs.tgpt}/bin/tgpt -q --key $GEMINI_API_KEY --provider gemini "$@"
  '';
  aiCommitScript = pkgs.writeShellScriptBin "nix-commit" ''
    cd /etc/nixos
    
    if [[ -z $(git status --porcelain) ]]; then
      echo "No changes to commit."
      exit 0
    fi

    git add .

    echo "--- Generating AI Commit Message ---"
    # Capture diff and send to AI
    DIFF=$(git diff --cached)
    PROMPT="Summarize these NixOS configuration changes into a single-line commit message using Conventional Commits format (e.g., feat:, fix:, chore:). Be concise. Output ONLY the message text."
    MESSAGE=$(echo "$DIFF" | ${tgptWrapped}/bin/tgpt-auth "$PROMPT")

    while true; do
      echo -e "\nProposed Message: \033[1;32m$MESSAGE\033[0m"
      echo -n "Action: [a]ccept, [e]dit, [r]egenerate, [c]ancel? "
      read -r opt
      case $opt in
        a) break ;;
        e) 
          echo -n "New message: "
          read -r MESSAGE
          break ;;
        r) 
          MESSAGE=$(echo "$DIFF" | ${tgptWrapped}/bin/tgpt-auth "$PROMPT")
          continue ;;
        c) 
          echo "Commit cancelled."
          exit 1 ;;
        *) echo "Invalid option." ;;
      esac
    done

    git commit -m "$MESSAGE"
    echo "Changes committed successfully."
  '';

  # The main wrapper
  nxs = pkgs.writeShellScriptBin "nxs" ''
    # Run build/switch via nh
    ${pkgs.nh}/bin/nh os switch "$@"

    # Only run commit logic if switch was successful
    if [ $? -eq 0 ]; then
      ${aiCommitScript}/bin/nix-commit
    fi
  '';
in {
  options.local.gitSync.enable = lib.mkEnableOption "Auto-commit with AI preview";

  config = lib.mkIf config.local.gitSync.enable {
    environment.systemPackages = [ 
      aiCommitScript 
      nxs 
      pkgs.tgpt 
    ];
    systemd.services.nixos-repo-push = {
      description = "Push /etc/nixos changes to remote";
      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Or your editor group
        WorkingDirectory = "/etc/nixos";
      };
      script = ''
        # Check if a remote is configured
        if ${pkgs.git}/bin/git remote | grep -q 'origin'; then
          ${pkgs.git}/bin/git push origin main
        fi
      '';
    };

    systemd.timers.nixos-repo-push = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
