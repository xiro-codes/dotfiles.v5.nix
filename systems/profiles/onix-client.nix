# Onix client profile - For systems connecting to Onix NAS
{ lib, ... }:
{
  local = {
    backup-manager = {
      enable = true;
      backupLocation = "/media/Backups";
      paths = [
        "/root/.ssh"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      exclude = [
        "*/.cache"
        "*/target"
        "*/node_modules"
        "*/.direnv"
        "*/known_hosts"
        "*/config"
        "*/result"
      ];
    };

    network-mounts = {
      enable = true;
      mounts = [
        {
          shareName = "backups";
          localPath = "/media/Backups";
          noAuth = true;
          noShow = true;
        }
        { shareName = "music"; localPath = "/media/Music"; }
        { shareName = "books"; localPath = "/media/Books"; }
      ];
    };
  };
}
