{ config, ... }:
{
  local.shares = {
    enable = true;
    shareDir = "/media/";
    nfs.enable = true;
    samba.enable = true;

    definitions = {
      media = {
        path = "/media/Media";
        comment = "Media files";
        guestOk = true;
        validUsers = [ "tod" ];
      };
      music = {
        path = "/media/Media/music";
        comment = "Music files";
        guestOk = true;
        validUsers = [ "tod" ];
      };
      backups = {
        path = "/media/Backups";
        comment = "Backup directory";
        guestOk = true;
        validUsers = [ "tod" ];
      };
    };
  };
}
