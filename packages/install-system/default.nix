{writeScriptBin, ...}: writeScriptBin "install-system" (builtins.readFile ./script.py)
