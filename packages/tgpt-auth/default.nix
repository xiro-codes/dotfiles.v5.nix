{ writeShellScriptBin, tgpt, lib, ... }: writeShellScriptBin "tgpt-auth" ''
  if [ -f /etc/nixos/gemini-key ]; then
    export GEMINI_API_KEY=$(sudo cat /etc/nixos/gemini-key)
  fi
  exec ${lib.getExe tgpt} -q --key $GEMINI_API_KEY --provider gemini "$@"
''
