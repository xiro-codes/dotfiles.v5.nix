{writeShellScriptBin, ...}: writeShellScriptBin "install-system" (builtins.readFile ./script.sh)
