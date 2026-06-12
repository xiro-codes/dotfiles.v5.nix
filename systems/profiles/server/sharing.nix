{ config, ... }:
{
  local = {
    file-sharing = {
      enable = true;
      shareDir = "/media/";
      nfs.enable = false;
      samba.enable = true;
      samba.openFirewall = true;

      definitions = {
        media = {
          path = "${config.local.media.mediaDir}";
          comment = "Media";
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
  };
}
