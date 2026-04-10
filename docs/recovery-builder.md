```markdown
# recovery-builder

This Nix module provides a systemd service and timer to automatically build and burn a recovery ISO image to a dedicated partition, typically labeled `disk-main-recovery`. This setup is designed to keep a regularly updated recovery image on the system, allowing for quick and easy restoration in case of system failure. The module uses `caligula` to efficiently burn the ISO to the partition without prompting for user interaction, and skips hash verification during the write process to optimize for speed. It's suitable for environments where an up-to-date recovery partition is desired without manual intervention.

## Options

### `local.recovery-builder.enable`

**Type:** `boolean`

**Default Value:** `false`

Enables or disables the recovery builder service and timer. When enabled, the module configures a systemd service and timer to automatically build and burn the recovery ISO weekly.

## Implementation Details

When `local.recovery-builder.enable` is set to `true`, the module configures the following systemd resources:

*   **Service: `recovery-builder.service`**

    *   **Description:**  "Build and burn recovery ISO"
    *   **Type:** `oneshot` - The service runs once and exits.
    *   **User:** `root` -  The service executes as the root user, required for partition access.
    *   **Nice:** `19` - Sets a low priority for the service to minimize impact on other processes.
    *   **CPUSchedulingPolicy:** `idle` - Uses the "idle" CPU scheduling policy, allowing other processes to preempt it.
    *   **IOSchedulingClass:** `idle` - Uses the "idle" I/O scheduling class, further reducing the impact on system responsiveness.
    *   **MemoryHigh:** `2G` - Limits the memory usage of the service to 2GB.
    *   **Path:** A list of packages required by the script:
        *   `git`: For version control, likely used internally by Nix to resolve dependencies.
        *   `nix`: The Nix package manager.
        *   `findutils`: For finding files (used to locate the generated ISO).
        *   `coreutils`: Provides essential command-line utilities.
        *   `caligula`: The tool used to burn the ISO to the partition.
    *   **Script:** The script performs the following actions:
        1.  **Find Recovery Partition:**  Uses `readlink -f /dev/disk/by-partlabel/disk-main-recovery` to determine the path to the recovery partition, identified by the label `disk-main-recovery`. The `|| true` part ensures that if the `readlink` command fails (partition not found), the script continues, but the PARTITION variable remains empty.
        2.  **Partition Check:** Checks if the `PARTITION` variable is empty or if the path it contains is not a block device. If either condition is true, it prints an error message and exits with code 0, preventing the build process if the partition is missing.
        3.  **Change Directory:** Changes the current directory to `/etc/nixos`.
        4.  **Build Recovery ISO:** Executes `nix build .#installer-iso --cores 2 --max-jobs 1` to build the ISO image using the Nix build system.  The `--cores 2` and `--max-jobs 1` parameters limit the resources used during the build, helping to avoid system overload.  It assumes that the NixOS configuration at `/etc/nixos` defines `installer-iso`.
        5.  **Burn ISO to Partition:** Uses `caligula burn $(find result/iso/ -name "*.iso" | head -n 1) -o "$PARTITION" --interactive never --compression none -f --hash skip` to burn the generated ISO to the identified partition.
            *   `$(find result/iso/ -name "*.iso" | head -n 1)`:  Finds the generated ISO file within the `result/iso/` directory (created by the `nix build` command) and takes the first match.
            *   `-o "$PARTITION"`: Specifies the target partition to write to.
            *   `--interactive never`: Disables interactive prompts from `caligula`.
            *   `--compression none`: Disables compression during the write process, potentially speeding it up.
            *   `-f`: Forces the write operation.
            *   `--hash skip`: Skips hash verification during the write process for faster operation.
        6.  **Success Message:** Prints a success message to indicate that the recovery ISO has been updated.

*   **Timer: `recovery-builder.timer`**

    *   **Description:** "Weekly recovery ISO builder timer"
    *   **WantedBy:** `timers.target` -  Ensures that the timer is started when the `timers.target` is reached during system boot.
    *   **TimerConfig:**
        *   **OnCalendar:** `weekly` -  Sets the timer to trigger weekly (every Sunday at 00:00 by default).
        *   **Persistent:** `true` - Ensures that the timer is triggered even if the system was powered off during its scheduled time.
        *   **Unit:** `recovery-builder.service` - Specifies the service to be executed when the timer triggers.
```
