{ config, ... }:
{
  # Example file sharing configuration
  # This shows how to set up NFS and Samba shares
  
  local.shares = {
    enable = true;
    
    # Enable both NFS and Samba
    nfs.enable = true;
    nfs.openFirewall = true;
    
    samba.enable = true;
    samba.openFirewall = true;
    samba.workgroup = "HOMELAB";
    samba.serverString = "NixOS Media Server";
    
    # Structured share definitions (recommended)
    # These automatically configure both Samba and NFS
    definitions = {
      # Public media share - read-only, guest access
      media = {
        path = "/srv/media";
        comment = "Media Library";
        readOnly = true;
        guestOk = true;
        browseable = true;
        enableNFS = true;
        nfsOptions = [ "ro" "sync" "no_subtree_check" ];
      };
      
      # Documents share - authenticated access
      documents = {
        path = "/srv/documents";
        comment = "Shared Documents";
        readOnly = false;
        guestOk = false;
        browseable = true;
        validUsers = [ "alice" "bob" ];
        enableNFS = true;
        nfsOptions = [ "rw" "sync" "no_subtree_check" ];
      };
      
      # Backups share - restricted access
      backups = {
        path = "/srv/backups";
        comment = "Backup Storage";
        readOnly = false;
        guestOk = false;
        browseable = false;
        validUsers = [ "admin" ];
        createMask = "0600";
        directoryMask = "0700";
        enableNFS = true;
        nfsOptions = [ "rw" "sync" "no_subtree_check" "no_root_squash" ];
        nfsClients = "192.168.1.100";  # Single IP only
      };
      
      # Downloads share - public write access
      downloads = {
        path = "/srv/downloads";
        comment = "Download Staging";
        readOnly = false;
        guestOk = true;
        writeable = true;
        browseable = true;
        enableNFS = false;  # Samba only
      };
    };
    
    # Advanced: Manual Samba share configuration
    # Use this for shares that need special options not covered by definitions
    samba.shares = {
      # timemachine = {
      #   path = "/srv/timemachine";
      #   "valid users" = "timemachine";
      #   "read only" = "no";
      #   "fruit:aapl" = "yes";
      #   "fruit:time machine" = "yes";
      #   "vfs objects" = "catia fruit streams_xattr";
      # };
    };
    
    # Advanced: Manual NFS exports
    # Use this for exports that need special options
    nfs.exports = ''
      # /srv/nfs-only 192.168.1.0/24(rw,async,no_subtree_check)
    '';
  };
  
  # To use these shares from a client, use share-manager:
  # local.shareManager = {
  #   enable = true;
  #   serverIp = config.local.hosts.server-hostname;
  #   noAuth = false;  # Set to true for guest access
  #   mounts = [
  #     { shareName = "media"; localPath = "/media/Media"; }
  #     { shareName = "documents"; localPath = "/media/Documents"; }
  #   ];
  # };
}
