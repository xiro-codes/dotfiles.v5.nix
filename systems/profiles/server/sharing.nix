{ config, ... }:
{
  local = {
    file-sharing = {
      enable = true;
      shareDir = "/media/";
      nfs.enable = false;
      samba.enable = true;

      definitions = {
        media = {
          path = "${config.local.media.mediaDir}";
          comment = "Media";
          validUsers = [ "tod" ];
        };
        music = {
          path = "${config.local.media.mediaDir}/music";
          comment = "Music";
          validUsers = [ "tod" ];
        };
        porn = {
          path = "${config.local.media.mediaDir}/porn";
          comment = "Porn";
          validUsers = [ "tod" ];
        };
        books = {
          path = "${config.local.media.mediaDir}/books";
          comment = "Books";
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
