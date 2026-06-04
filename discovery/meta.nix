{ }:
let
  inherit (builtins) pathExists;
in
rec {
  readMeta = file: 
    if file != null && pathExists file then import file else { };
  
  isBroken = file: 
    (readMeta file).broken or false;
    
  getDescription = file: 
    (readMeta file).description or null;

  getWhatWithDescription = what: file:
    let
      desc = getDescription file;
    in
    if desc != null then "${what}: ${desc}" else what;
}