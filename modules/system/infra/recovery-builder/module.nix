{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.local.recovery-builder;
in
{
  options.local.recovery-builder = {
    enable = mkEnableOption "Recovery Builder";
  };

  config = mkIf cfg.enable {
    systemd.services.recovery-builder = {
      description = "Build and burn recovery ISO";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        # Use low resources
        MemoryHigh = "2G";
      };
      path = with pkgs; [
        git
        nix
        findutils
        coreutils
        caligula
      ];
      script = ''
        PARTITION=$(readlink -f /dev/disk/by-partlabel/disk-main-recovery || true)
        if [ -z "$PARTITION" ] || [ ! -b "$PARTITION" ]; then
          echo "Recovery partition (disk-main-recovery) not found. Skipping."
          exit 0
        fi

        cd /etc/nixos
        echo "Building recovery ISO..."
        nix build .#installer-iso --cores 2 --max-jobs 1

        echo "Burning ISO to recovery partition..."
        caligula burn $(find result/iso/ -name "*.iso" | head -n 1) -o "$PARTITION" --interactive never --compression none -f --hash skip

        echo "Failsafe ISO updated successfully."
      '';
    };

    systemd.timers.recovery-builder = {
      description = "Weekly recovery ISO builder timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        Unit = "recovery-builder.service";
      };
    };
  };
}
