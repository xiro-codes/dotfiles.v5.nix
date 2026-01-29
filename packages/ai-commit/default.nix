{ writeShellScriptBin
, callPackage
, lib
, ...
}:
let
  tgpt-auth = callPackage ../tgpt-auth/default.nix { };
in
writeShellScriptBin "ai-commit" ''
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Not a git repo. Exiting."
    exit 1
  fi

  if [[ -z $(git status --porcelain) ]]; then
    echo "No changes to commit."
    exit 0
  fi
  git add .
  echo "--- Generating AI Commit Message ---"
  DIFF=$(git diff --cached)
  PROMPT="Summarize these changes into a single-line commit message using Conventional Commits format (e.g., feat:, fix:, chore:, etc). Be concise. Output ONLY the message text."
  MESSAGE=$(echo "$DIFF" | ${lib.getExe tgpt-auth} "$PROMPT")
  while true; do
    echo -e "\nProposed Message: \033[1;32m$MESSAGE\033[0m"
    echo -n "Action: [a]ccept, [e]dit, [r]egenerate, [c]ancel?"
    read -r opt
    case $opt in
      a) break ;;
      e)
        echo -n "New message: "
        read -r MESSAGE
        break ;;
      r)
        MESSAGE=$(echo "$DIFF" | ${lib.getExe tgpt-auth} "$PROMPT")
        continue ;;
      c)
        echo "Commit cancelled."
        exit 1 ;;
      *) echo "Invalid option." ;;
    esac
  done
  git commit -m "$MESSAGE"
  echo "Changes committed successfully."
''
