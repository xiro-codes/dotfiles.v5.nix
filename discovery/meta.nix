{ }:
let
  inherit (builtins) pathExists;
  esc = builtins.fromJSON ''"\u001b"'';
  strikethrough = "${esc}[9m";
  reset = "${esc}[0m";
in
rec {
  readMeta = file: 
    if file != null && pathExists file then import file else { };
  
  isBroken = file: 
    (readMeta file).broken or false;
    
  isUnstable = file:
    (readMeta file).unstable or false;

  getDescription = file: 
    (readMeta file).description or null;

  formatWhat = what: desc: broken:
    let
      baseText = if desc != null then "${what}: ${desc}" else what;
    in
    if broken then "${strikethrough}${baseText}${reset} (RIP)" else baseText;

  getWhatWithDescription = what: file:
    formatWhat what (getDescription file) (isBroken file);
}