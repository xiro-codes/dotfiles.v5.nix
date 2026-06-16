# Sapphire client profile - For systems connecting to Sapphire NAS
{ lib, self, ... }:
{
  imports = [
    self.nixosModules."admin/backup-manager"
    self.nixosModules."networking/network-mounts"
    self.nixosModules."infra/recovery-builder"
  ];
  local = {
    recovery-builder.enable = true;
    dotfiles-sync.maintenance.autoUpgrade = true;

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
          noShow = true;
          options = [ "vers=3.0" ];
        }
        {
          shareName = "media";
          localPath = "/media/Media";
          options = [ "vers=3.0" ];
        }
        {
          shareName = "scratch";
          localPath = "/media/Scratch";
          options = [ "vers=3.0" ];
        }
      ];
    };
  };
}
