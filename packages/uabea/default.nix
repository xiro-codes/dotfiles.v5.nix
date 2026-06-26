{
  lib,
  stdenv,
  gnumake,
  fontconfig,
  xorg,
  libGL,
  libxkbcommon,
  glib,
  makeWrapper,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:

buildDotnetModule rec {
  pname = "uabea";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "nesrak1";
    repo = "UABEA";
    rev = "v8";
    sha256 = "1p5va3fm48wbqn8fcgx8dbral5lbwxzxdsaf93rdfjznnn8zcpc7";
  };

  projectFile = "UABEAvalonia.sln";
  nugetDeps = ./deps.json;
  
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nativeBuildInputs = [
    stdenv.cc
    gnumake
    fontconfig
    xorg.libX11
    xorg.libICE
    xorg.libSM
    makeWrapper
  ];

  runtimeLibs = [
    stdenv.cc.cc.lib
    fontconfig
    xorg.libX11
    xorg.libICE
    xorg.libSM
    xorg.libXcursor
    xorg.libXi
    xorg.libXext
    xorg.libXrandr
    libGL
    libxkbcommon
    glib
  ];

  buildPhase = ''
    runHook preBuild
    export LD_LIBRARY_PATH=${lib.makeLibraryPath [ fontconfig xorg.libX11 xorg.libICE xorg.libSM ]}:$LD_LIBRARY_PATH
    dotnet build ''${projectFile} --configuration Release --no-restore
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/lib/uabea
    
    cp UABEAvalonia/bin/Release/net8.0/runtimes/linux/native/libonigwrap.so UABEAvalonia/bin/Release/net8.0/runtimes/linux-x64/native/libonigwrap.so || true
    find UABEAvalonia/bin/Release/net8.0/runtimes/* -maxdepth 0 ! -name linux-x64 -type d -exec rm -r {} + || true
    
    cp -r UABEAvalonia/bin/Release/net8.0/* $out/lib/uabea/
    
    makeWrapper ${dotnetCorePackages.runtime_8_0}/bin/dotnet $out/bin/uabea \
      --add-flags "$out/lib/uabea/UABEAvalonia.dll" \
      --set DOTNET_ROOT ${dotnetCorePackages.runtime_8_0} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ "${placeholder "out"}" ]}:${lib.makeLibraryPath runtimeLibs}
      
    runHook postInstall
  '';

  postPatch = ''
    find . -type f -name "*.csproj" -exec sed -i 's/net6.0/net8.0/g' {} +
    dotnet sln ''${projectFile} remove TexToolWrap/TexToolWrap.vcxproj
  '';

  executables = [ "UABEAvalonia" ];

  meta = with lib; {
    description = "Unity Asset Bundle Extractor Avalon";
    homepage = "https://github.com/nesrak1/UABEA";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
