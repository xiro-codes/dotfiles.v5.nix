# File Sharing with NFS and Samba

This guide covers setting up file shares using the `local.shares` module (server-side) and accessing them with `local.shareManager` (client-side).

## Overview

The file sharing system provides:
- **Samba/CIFS** - Compatible with Windows, macOS, and Linux
- **NFS** - High-performance sharing for Unix/Linux systems
- **Unified Configuration** - Define shares once, automatically configure both protocols
- **Automatic Discovery** - Works with Avahi for `.local` domain resolution
- **Access Control** - Per-share authentication and permissions

## Quick Start (Server)

### Simple Configuration

```nix
local.shares = {
  enable = true;
  
  samba.enable = true;
  samba.openFirewall = true;
  
  definitions = {
    media = {
      path = "/srv/media";
      comment = "Media Files";
      readOnly = true;
      guestOk = true;
    };
  };
};
```

Access from Windows: `\\\\hostname.local\\media`
Access from Linux: `smb://hostname.local/media`

## Structured Share Definitions

The recommended way to configure shares is using `definitions`. This automatically sets up both Samba and NFS (if enabled).

### Basic Share

```nix
definitions = {
  public = {
    path = "/srv/public";
    comment = "Public Files";
    readOnly = false;
    guestOk = true;
    browseable = true;
  };
};
```

### Authenticated Share

```nix
definitions = {
  private = {
    path = "/srv/private";
    comment = "Private Documents";
    readOnly = false;
    guestOk = false;
    validUsers = [ "alice" "bob" ];
    browseable = true;
  };
};
```

### Media Share with NFS

```nix
definitions = {
  media = {
    path = "/srv/media";
    comment = "Media Library";
    readOnly = true;
    guestOk = true;
    enableNFS = true;
    nfsOptions = [ "ro" "sync" "no_subtree_check" ];
    nfsClients = "192.168.1.0/24";
  };
};
```

## Share Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `path` | string | required | Absolute path to share directory |
| `comment` | string | `""` | Description shown to users |
| `readOnly` | bool | `false` | Make share read-only |
| `guestOk` | bool | `false` | Allow guest access (no password) |
| `browseable` | bool | `true` | Show in network browse lists |
| `validUsers` | list | `[]` | List of allowed users (empty = all) |
| `writeable` | bool | `true` | Allow write access (if not readOnly) |
| `createMask` | string | `"0664"` | Permissions for new files |
| `directoryMask` | string | `"0775"` | Permissions for new directories |
| `enableNFS` | bool | `false` | Also export via NFS |
| `nfsOptions` | list | `["rw","sync","no_subtree_check"]` | NFS export options |
| `nfsClients` | string | `"192.168.0.0/16"` | Network range for NFS |

## Server Configuration

### Enable Services

```nix
local.shares = {
  enable = true;
  
  # Base directory for shares
  shareDir = "/srv/shares";
  
  # Samba configuration
  samba = {
    enable = true;
    openFirewall = true;
    workgroup = "WORKGROUP";
    serverString = "NixOS File Server";
  };
  
  # NFS configuration
  nfs = {
    enable = true;
    openFirewall = true;
  };
};
```

### User Authentication

For Samba authentication, you need to create Samba users:

```bash
# Create a Samba user (requires system user exists)
sudo smbpasswd -a username

# Enable the user
sudo smbpasswd -e username

# Change password
sudo smbpasswd username
```

## Client Configuration (share-manager)

The `share-manager` module automatically mounts Samba shares from a server.

### Basic Mount

```nix
local.shareManager = {
  enable = true;
  serverIp = config.local.hosts.server;  # Or "192.168.1.100"
  noAuth = false;  # Requires credentials
  
  mounts = [
    {
      shareName = "media";
      localPath = "/media/Media";
    }
  ];
};
```

### Guest Access

```nix
local.shareManager = {
  enable = true;
  serverIp = "server.local";
  noAuth = true;  # Guest access, no password
  
  mounts = [
    {
      shareName = "public";
      localPath = "/media/Public";
    }
  ];
};
```

### With Credentials

For authenticated access, store credentials in sops:

1. Create credential file:
```
username=myuser
password=mypassword
```

2. Add to sops secrets
3. Reference in configuration:

```nix
local.shareManager = {
  enable = true;
  serverIp = config.local.hosts.server;
  secretName = "smb_credentials";  # Name in sops
  
  mounts = [
    {
      shareName = "private";
      localPath = "/media/Private";
    }
  ];
};
```

### Hide from File Manager

```nix
mounts = [
  {
    shareName = "backups";
    localPath = "/media/Backups";
    noShow = true;  # Hide from file manager
  }
];
```

## Advanced Configuration

### Manual Samba Configuration

For shares requiring special Samba options not covered by `definitions`:

```nix
samba.shares = {
  timemachine = {
    path = "/srv/timemachine";
    "valid users" = "backup";
    "read only" = "no";
    "fruit:aapl" = "yes";
    "fruit:time machine" = "yes";
    "vfs objects" = "catia fruit streams_xattr";
  };
};
```

### Manual NFS Exports

For custom NFS exports:

```nix
nfs.exports = ''
  /srv/nfs-special 192.168.1.0/24(rw,async,no_subtree_check,no_root_squash)
  /srv/readonly 10.0.0.0/8(ro,sync,no_subtree_check)
'';
```

### Mixed Configuration

You can use both structured definitions and manual configuration:

```nix
local.shares = {
  enable = true;
  samba.enable = true;
  
  # Structured shares (recommended)
  definitions = {
    media = {
      path = "/srv/media";
      readOnly = true;
      guestOk = true;
    };
  };
  
  # Manual shares (for special cases)
  samba.shares = {
    special = {
      path = "/srv/special";
      "vfs objects" = "full_audit";
      "full_audit:prefix" = "%u|%I|%m|%S";
    };
  };
};
```

## Ports and Firewall

### Samba Ports
- TCP 139, 445 (SMB)
- TCP/UDP 137, 138 (NetBIOS)
- UDP 3702 (WS-Discovery for Windows)

### NFS Ports
- TCP/UDP 111 (portmapper)
- TCP/UDP 2049 (NFS)
- TCP/UDP 4000, 4001, 4002 (lockd, mountd, statd)
- TCP/UDP 20048 (mountd)

Set `openFirewall = true` to automatically open required ports.

## Access Methods

### From Windows

**File Explorer:**
1. Open File Explorer
2. Type in address bar: `\\hostname.local\sharename`
3. Or: `\\192.168.1.100\sharename`

**Map Network Drive:**
1. Right-click "This PC" → "Map network drive"
2. Enter path: `\\hostname.local\media`
3. Check "Reconnect at sign-in"

### From macOS

**Finder:**
1. Cmd+K or Go → Connect to Server
2. Enter: `smb://hostname.local/sharename`
3. Or: `nfs://hostname.local/srv/media`

**Terminal (NFS):**
```bash
sudo mount -t nfs hostname.local:/srv/media /mnt/media
```

### From Linux

**Nautilus/Files:**
1. Other Locations → Connect to Server
2. Enter: `smb://hostname.local/sharename`

**Command Line (Samba):**
```bash
# Mount temporarily
sudo mount -t cifs //hostname.local/media /mnt/media -o user=username

# Or use share-manager module (recommended)
```

**Command Line (NFS):**
```bash
sudo mount -t nfs hostname.local:/srv/media /mnt/media
```

## Integration with Other Modules

### Media Server Shares

Share your media directories:

```nix
local.media.mediaDir = "/srv/media";

local.shares = {
  enable = true;
  samba.enable = true;
  
  definitions = {
    media = {
      path = config.local.media.mediaDir;
      readOnly = true;
      guestOk = true;
      enableNFS = true;
    };
  };
};
```

### Download Shares

Share download directories:

```nix
local.download.downloadDir = "/srv/downloads";

local.shares = {
  enable = true;
  samba.enable = true;
  
  definitions = {
    downloads = {
      path = config.local.download.downloadDir;
      readOnly = false;
      guestOk = true;
    };
  };
};
```

## Troubleshooting

### Cannot Connect to Shares

1. Check services are running:
```bash
systemctl status smbd nmbd
systemctl status nfs-server
```

2. Verify firewall:
```bash
sudo nft list ruleset | grep -E "445|2049"
```

3. Test Samba from server:
```bash
smbclient -L localhost -N
```

4. Check Avahi resolution:
```bash
avahi-resolve -n hostname.local
```

### Permission Denied

1. Check directory permissions:
```bash
ls -la /srv/shares
```

2. Verify Samba user exists:
```bash
sudo pdbedit -L
```

3. Check SELinux/AppArmor (if applicable)

### Slow Performance

1. For large files, use NFS instead of Samba
2. Adjust Samba performance settings:
```nix
samba.shares.myshare = {
  "read raw" = "yes";
  "write raw" = "yes";
  "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
};
```

### Shares Not Visible

1. Check `browseable = true` in share config
2. Verify Samba WSDD is running:
```bash
systemctl status wsdd
```

3. Windows: Run `\\hostname.local` in address bar

## Security Best Practices

1. **Use Authentication** - Avoid `guestOk` for sensitive data
2. **Restrict Networks** - Use firewall rules to limit access
3. **Read-Only Shares** - Make media shares read-only
4. **Separate Users** - Create dedicated Samba users
5. **Monitor Access** - Check logs regularly:
```bash
journalctl -u smbd -f
journalctl -u nfs-server -f
```

6. **Use VPN** - For access outside local network
7. **Backup Credentials** - Store sops secrets securely

## Complete Example

See `systems/profiles/shares-example.nix` for a complete configuration with multiple share types.
