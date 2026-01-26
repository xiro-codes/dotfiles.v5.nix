{ writeShellApplication, wf-recorder, slurp, libnotify, procps, ... }: writeShellApplication {
  name = "recording-toggle";
  runtimeInputs = [
    wf-recorder
    slurp
    libnotify
    procps
  ];
  text = builtins.readFile ./script.sh;
}
