{ config, ... }:
{
  local.shares = {
    enable = true;
    shareDir = "/media/";
    nfs.enable = true;
    samba.enable = true;
    definitions = {
      Media = {
        path = "/media/Media";
        comment = "Media files";
        guestOk = true;
      };
      Music = {
        path = "/media/Media/Music";
        comment = "Music files";
        guestOk = true;
      };
      Backups = {
        path = "/media/Backups";
        comment = "Backup directory";
        guestOk = true;
      };
    };
  };
}
