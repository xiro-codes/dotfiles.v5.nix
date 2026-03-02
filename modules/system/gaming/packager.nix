{ pkgs, lib, ... }:
let
  mkNativeGame = name: src: pkgs.stdenv.mkDerivation {
    inherit name src;
    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = "sh $src --extract .";
    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/
      [ -f $out/start.sh ] && ln -s $out/start.sh $out/bin/${lib.toLower name}
    '';

  };
  mkWineGame = name: src: pkgs.stdenv.mkDerivation {
    inherit name src;
    nativeBuildInputs = [ pkgs.innoextract pkgs.makeWrapper ];
    buildInputs = [ pkgs.wineWow64Packages.stable ];
    unpackPhase = "innoextract -e $src";
    installPhase = ''
      mkdir -p $out/share/${name}
      cp -r * $out/share/${name}
      # Create a wrapper that runs the game in its own prefix
      makeWrapper ${pkgs.wineWow64Packages.stable}/bin/wine $out/bin/${lib.toLower name} \
        --add-flags "$out/share/${name}/app/game.exe" \
        --set WINEPREFIX "$HOME/.local/share/wineprefixes/${name}"
    '';
  };
  shouldSkip = dir: path:
    let content = builtins.readDir path;
    in builtins.hasAttr ".DONT-INSTALL" content;
in
{
  scanAndPackage = dir:
    let
      log = builtins.trace "!!!!! ${dir}" dir;
      files = builtins.attrNames (builtins.readDir dir);
      validFiles = builtins.filter
        (
          file:
          let
            path = "${toString dir}/${file}";
            isInstaller = lib.hasSuffix ".sh" file || lib.hasSuffix ".exe" file;
            skipped = shouldSkip dir dir;
          in
          isInstaller && !shouldSkip
        )
        files;
      processFile = file:
        let
          path = "${toString dir}/${file}";
          name = lib.removeSuffix ".sh" (lib.removeSuffix ".exe" file);
          isLinux = lib.hasSuffix ".sh" file;
        in
        {
          inherit name;
          value =
            if isLinux
            then mkNativeGame name path
            else mkWineGame name path;
        };
    in
    builtins.seq log (builtins.listToAttrs (map processFile validFiles));
}
