{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "tekkit-server";
  version = "3.1.2";

  src = ./Tekkit_Server_3.1.2.zip;

  nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper ];

  dontBuild = true;

  unpackPhase = ''
    mkdir -p $out/lib/tekkit-server
    unzip -q $src -d $out/lib/tekkit-server
  '';

  installPhase = ''
        mkdir -p $out/bin
    
        cat > $out/bin/minecraft-server <<EOF
    #!/bin/sh
    export PATH="${pkgs.coreutils}/bin:\$PATH"
    for f in $out/lib/tekkit-server/*; do
      target="\$(basename "\$f")"
      if [ ! -e "\$target" ]; then
        cp -r "\$f" "\$target"
        chmod -R u+w "\$target"
      fi
    done

    exec ${pkgs.jre8}/bin/java "\$@" -jar $out/lib/tekkit-server/Tekkit.jar nogui
    EOF

        chmod +x $out/bin/minecraft-server
  '';
}

