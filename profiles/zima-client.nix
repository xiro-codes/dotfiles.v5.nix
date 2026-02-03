# Zima client profile - For systems connecting to ZimaOS NAS
{ lib, ... }:
{
  local = {
    backup-manager = {
      enable = true;
      backupLocation = "/mnt/zima/Backups";
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
    
    shareManager = {
      enable = true;
      serverIp = "10.0.0.65";
      mounts = [
        { 
          shareName = "Backups"; 
          localPath = "/mnt/zima/Backups"; 
          noAuth = true;
          noShow = true;
        }
        { shareName = "Music"; localPath = "/mnt/zima/Music"; }
        { shareName = "Books"; localPath = "/mnt/zima/Books"; }
      ];
    };
  };
}
