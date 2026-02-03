{ inputs, lib, ... }:
let
  paths = import ./discovery/paths.nix;
  fs = import ./discovery/fs.nix { inherit lib; };
  modulesLib = import ./discovery/modules.nix { inherit fs; };
  
  discoveredSystemModules = modulesLib.mkModules paths.systemModules;
  discoveredHomeModules = modulesLib.mkModules paths.homeModules;
in
{
  perSystem = { pkgs, system, ... }:
    let
      # Generate documentation for system modules
      systemModuleDocs =
        let
          # Minimal evaluation wrapper to extract just options
          eval = lib.evalModules {
            modules = [
              { _module.check = false; }
            ] ++ (lib.attrValues discoveredSystemModules);
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
          };

      # Generate documentation for home modules  
      homeModuleDocs =
        let
          eval = lib.evalModules {
            modules = [
              { _module.check = false; }
              { 
                # Stub out config.home to avoid evaluation errors
                home.username = lib.mkDefault "docs";
                home.homeDirectory = lib.mkDefault "/home/docs";
                home.stateVersion = lib.mkDefault "24.05";
              }
            ] ++ (lib.attrValues discoveredHomeModules);
            specialArgs = { inherit inputs pkgs; osConfig = {}; };
          };
          localOptions = eval.options.local or null;
        in
        if localOptions == null then
          { optionsCommonMark = pkgs.writeText "home-modules.md" "No home modules found.\n"; }
        else
          pkgs.nixosOptionsDoc {
            options = localOptions;
          };

      # Combine into a single documentation package
      allDocs = pkgs.runCommand "dotfiles-docs" {} ''
        mkdir -p $out
        
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
      '';
      
    in {
      packages = {
        docs = allDocs;
        
        # Convenience package to view docs
        view-docs = pkgs.writeShellScriptBin "view-docs" ''
          ${pkgs.glow}/bin/glow ${allDocs}/README.md
        '';
      };
    };
}
