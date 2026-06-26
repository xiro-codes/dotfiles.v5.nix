{
  lib,
  stdenv,
  gnumake,
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
  ];

  dotnetFlags = [
    "-p:UseAppHost=false"
  ];

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
