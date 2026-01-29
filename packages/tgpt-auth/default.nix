{ writeShellScriptBin, tgpt, lib, ... }: writeShellScriptBin "tgpt-auth" ''
  if [ -z "$GEMINI_API_KEY" ]; then
    if [ -f "/run/secrets/gemini/api_key" ]; then
      export GEMINI_API_KEY=$(cat /run/secrets/gemini/api_key)
    elif [ -f "/etc/nixos/gemini-key" ]; then
      export GEMINI_API_KEY=$(sudo cat /etc/nixos/gemini-key)
    fi
  fi
  if [ -z "$GEMINI_API_KEY" ]; then
    echo "No Gemini API key found in /run/secrets/gemini/api_key or /etc/nixos/gemini-key"
    exit 1
  fi
  exec ${lib.getExe tgpt} -q --key $GEMINI_API_KEY --provider gemini "$@"
''
