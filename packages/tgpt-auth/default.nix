{ writeShellScriptBin, tgpt, lib, ... }:
let
  geminiKeyPath = "$HOME/.secrets/gemini/api_key";
in
writeShellScriptBin "tgpt-auth" ''
  if [ -f "${geminiKeyPath}" ]; then
    export GEMINI_API_KEY=$(cat ${geminiKeyPath})
  fi
  if [ -z "$GEMINI_API_KEY" ]; then
    echo "No Gemini API key found in /run/secrets/gemini/api_key or /etc/nixos/gemini-key"
    exit 1
  fi
  exec ${lib.getExe tgpt} -q --key $GEMINI_API_KEY --provider gemini "$@"
''
