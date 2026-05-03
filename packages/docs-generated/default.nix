{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # This discovery logic is now self-contained within the package
  paths = import ../../parts/discovery/paths.nix;
  fs = import ../../parts/discovery/fs.nix { inherit lib; };
  modulesLib = import ../../parts/discovery/modules.nix { inherit fs; };

  discoveredSystemModules = modulesLib.mkModules paths.systemModules;
  discoveredHomeModules = modulesLib.mkModules paths.homeModules;

  # Generate documentation for system modules
  systemModuleDocs =
    let
      eval = lib.evalModules {
        modules = [
          { _module.check = false; }
        ]
        ++ (lib.attrValues discoveredSystemModules);
        specialArgs = {
          currentHostUsers = [ ];
          currentHostName = "docs";
          inherit inputs pkgs;
        };
      };
      localOptions = eval.options.local or null;
    in
    if localOptions == null then
      { optionsCommonMark = pkgs.writeText "system-modules.md" "No system modules found.\n"; }
    else
      pkgs.nixosOptionsDoc {
        options = localOptions;
        transformOptions =
          opt:
          let
            flakeRoot = toString inputs.self;
            cleanStr =
              str:
              if builtins.isString str && lib.hasPrefix flakeRoot str then
                "flake:" + lib.removePrefix flakeRoot str
              else
                str;
          in
          opt
          // {
            declarations = map (
              decl:
              let
                pathStr = toString decl;
              in
              if lib.hasPrefix flakeRoot pathStr then
                {
                  name = "flake:" + lib.removePrefix flakeRoot pathStr;
                  url = "flake:" + lib.removePrefix flakeRoot pathStr;
                }
              else
                decl
            ) opt.declarations;
            default =
              if opt ? default && opt.default != null && opt.default ? text then
                opt.default // { text = cleanStr opt.default.text; }
              else if opt ? default then
                cleanStr opt.default
              else
                null;
            example =
              if opt ? example && opt.example != null && opt.example ? text then
                opt.example // { text = cleanStr opt.example.text; }
              else if opt ? example then
                cleanStr opt.example
              else
                null;
            description = if opt ? description then cleanStr opt.description else null;
          };
      };

  # Generate documentation for home modules
  homeModuleDocs =
    let
      eval = lib.evalModules {
        modules = [
          { _module.check = false; }
          {
            home.username = lib.mkDefault "docs";
            home.homeDirectory = lib.mkDefault "/home/docs";
            home.stateVersion = lib.mkDefault "24.05";
          }
        ]
        ++ (lib.attrValues discoveredHomeModules);
        specialArgs = {
          inherit inputs pkgs;
          osConfig = { };
        };
      };
      localOptions = eval.options.local or null;
    in
    if localOptions == null then
      { optionsCommonMark = pkgs.writeText "home-modules.md" "No home modules found.\n"; }
    else
      pkgs.nixosOptionsDoc {
        options = localOptions;
        transformOptions =
          opt:
          let
            flakeRoot = toString inputs.self;
            cleanStr =
              str:
              if builtins.isString str && lib.hasPrefix flakeRoot str then
                "flake:" + lib.removePrefix flakeRoot str
              else
                str;
          in
          opt
          // {
            declarations = map (
              decl:
              let
                pathStr = toString decl;
              in
              if lib.hasPrefix flakeRoot pathStr then
                {
                  name = "flake:" + lib.removePrefix flakeRoot pathStr;
                  url = "flake:" + lib.removePrefix flakeRoot pathStr;
                }
              else
                decl
            ) opt.declarations;
            default =
              if opt ? default && opt.default != null && opt.default ? text then
                opt.default // { text = cleanStr opt.default.text; }
              else if opt ? default then
                cleanStr opt.default
              else
                null;
            example =
              if opt ? example && opt.example != null && opt.example ? text then
                opt.example // { text = cleanStr opt.example.text; }
              else if opt ? example then
                cleanStr opt.example
              else
                null;
            description = if opt ? description then cleanStr opt.description else null;
          };
      };
in
# Combine into a single documentation package
pkgs.runCommand "dotfiles-docs" {
  nativeBuildInputs = [ pkgs.python3 ];
} ''
  mkdir -p $out/system $out/home

  cat << 'EOF' > split.py
import json
import os
import sys

def process(json_path, out_dir):
    if not os.path.exists(json_path): return
    with open(json_path, "r") as f:
        data = json.load(f)
    
    modules = {}
    for opt_name, opt_data in data.items():
        if opt_name == "_module.args": continue
        decls = opt_data.get("declarations", [])
        mod_name = "unknown"
        for decl in decls:
            name = decl.get("name", "") if isinstance(decl, dict) else str(decl)
            if name.startswith("flake:/modules/system/"):
                mod_name = name.split("/")[3]
                break
            elif name.startswith("flake:/modules/home/"):
                mod_name = name.split("/")[3]
                break
        
        if mod_name not in modules:
            modules[mod_name] = []
        modules[mod_name].append((opt_name, opt_data))
    
    for mod_name, opts in modules.items():
        with open(os.path.join(out_dir, f"{mod_name}.md"), "w") as f:
            for opt_name, opt_data in opts:
                f.write(f"### `{opt_name}`\n\n")
                if "type" in opt_data:
                    f.write(f"**Type:** {opt_data['type']}\n\n")
                if "default" in opt_data and opt_data["default"] is not None:
                    val = opt_data["default"].get("text", str(opt_data["default"])) if isinstance(opt_data["default"], dict) else str(opt_data["default"])
                    f.write(f"**Default:**\n```nix\n{val}\n```\n\n")
                if "example" in opt_data and opt_data["example"]:
                    val = opt_data["example"].get("text", str(opt_data["example"])) if isinstance(opt_data["example"], dict) else str(opt_data["example"])
                    f.write(f"**Example:**\n```nix\n{val}\n```\n\n")
                if "description" in opt_data and opt_data["description"]:
                    f.write(f"**Description:**\n{opt_data['description']}\n\n")

if __name__ == "__main__":
    process(sys.argv[1], sys.argv[2])
EOF

  if [ -d ${systemModuleDocs.optionsJSON}/share/doc/nixos ]; then
    python3 split.py ${systemModuleDocs.optionsJSON}/share/doc/nixos/options.json $out/system
  fi
  if [ -d ${homeModuleDocs.optionsJSON}/share/doc/nixos ]; then
    python3 split.py ${homeModuleDocs.optionsJSON}/share/doc/nixos/options.json $out/home
  fi

  echo "# NixOS Dotfiles Documentation" > $out/README.md
  echo "" >> $out/README.md
  echo "Auto-generated documentation for custom modules." >> $out/README.md
  echo "" >> $out/README.md

  if [ -f ${systemModuleDocs.optionsCommonMark} ]; then
    echo "## System Modules" >> $out/README.md
    echo "" >> $out/README.md
    cat ${systemModuleDocs.optionsCommonMark} >> $out/README.md
    echo "" >> $out/README.md
  fi

  if [ -f ${homeModuleDocs.optionsCommonMark} ]; then
    echo "## Home Manager Modules" >> $out/README.md
    echo "" >> $out/README.md
    cat ${homeModuleDocs.optionsCommonMark} >> $out/README.md
  fi

  # Copy individual files too
  cp ${systemModuleDocs.optionsCommonMark} $out/system-modules.md 2>/dev/null || true
  cp ${homeModuleDocs.optionsCommonMark} $out/home-modules.md 2>/dev/null || true
''
