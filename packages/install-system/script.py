#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import time
import argparse
from typing import List, Optional, Dict


def run_cmd(cmd: List[str], cwd: Optional[str] = None) -> None:
    """
    Executes a system command and handles failure by exiting the script.

    Args:
        cmd: A list of strings representing the command and its arguments.
        cwd: Optional directory to execute the command in.
    """
    try:
        subprocess.run(cmd, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Command failed: {' '.join(cmd)}")
        sys.exit(1)


def get_target_disk(override: Optional[str] = None) -> str:
    """
    Detects the best disk for installation or uses the provided override.
    Prioritizes nvme, then vd (virtio), then sd (sata/scsi).

    Args:
        override: An optional disk path (e.g., /dev/sda) to bypass detection.

    Returns:
        The path to the selected disk device.
    """
    if override:
        return override

    try:
        lsblk = subprocess.check_output(["lsblk", "-dno", "NAME,TYPE"], text=True)
        for priority in ["nvme", "vd", "sd"]:
            for line in lsblk.splitlines():
                if priority in line and "disk" in line:
                    return f"/dev/{line.split()[0]}"
    except subprocess.CalledProcessError:
        pass

    print("❌ No disk detected!")
    sys.exit(1)


def partition_and_format(disk: str) -> str:
    """
    Wipes the target disk and creates a basic GPT partition layout:
    1. ESP (EFI System Partition) - 512MiB, FAT32
    2. Primary Partition - Remaining space, EXT4 (labeled 'nixos')

    Args:
        disk: The path to the disk device to partition.

    Returns:
        The path to the newly created boot partition.
    """
    suffix = "p" if "nvme" in disk else ""
    boot_p = f"{disk}{suffix}1"
    root_p = f"{disk}{suffix}2"

    print(f"🏗️  Partitioning {disk}...")
    run_cmd(["parted", "-s", disk, "--", "mklabel", "gpt"])
    run_cmd(["parted", "-s", disk, "--", "mkpart", "ESP", "fat32", "1MiB", "512MiB"])
    run_cmd(["parted", "-s", disk, "--", "set", "1", "esp", "on"])
    run_cmd(["parted", "-s", disk, "--", "mkpart", "primary", "ext4", "512MiB", "100%"])

    run_cmd(["partprobe", disk])
    time.sleep(2)

    print(f"🧹 Formatting...")
    run_cmd(["mkfs.fat", "-F32", boot_p])
    run_cmd(["mkfs.ext4", "-L", "nixos", root_p])

    return boot_p


def generate_configs(args: argparse.Namespace) -> None:
    """
    Clones the dotfiles repository and initializes configurations using templates.
    Instead of copying a local path, it fetches the latest code from Git.

    Args:
        args: The parsed command line arguments.
    """
    dest_repo = "/mnt/etc/nixos"

    print(f"📡 Cloning repository from {args.repo}...")
    os.makedirs("/mnt/etc", exist_ok=True)

    # Clean up existing destination if it somehow exists
    if os.path.exists(dest_repo):
        shutil.rmtree(dest_repo)

    run_cmd(["git", "clone", args.repo, dest_repo])
    os.chdir(dest_repo)

    # 1. Initialize Home Configuration
    print(f"🏠 Initializing home config for {args.user}...")
    os.makedirs("home", exist_ok=True)
    run_cmd(["nix", "flake", "init", "-t", ".#home-config"], cwd="home")

    home_file = f"home/{args.user}@{args.host}.nix"
    if os.path.exists("home/default.nix"):
        os.rename("home/default.nix", home_file)
    run_cmd(["sed", "-i", f"s/USERNAME/{args.user}/g", home_file])

    # 2. Initialize System Configuration
    print(f"🖥️  Initializing system config for {args.host}...")
    sys_dir = f"systems/{args.host}"
    os.makedirs(sys_dir, exist_ok=True)
    run_cmd(["nix", "flake", "init", "-t", ".#system-config"], cwd=sys_dir)

    config_file = f"{sys_dir}/configuration.nix"
    if os.path.exists(f"{sys_dir}/default.nix"):
        os.rename(f"{sys_dir}/default.nix", config_file)

    # Apply template replacements
    replacements: Dict[str, str] = {
        "TEMPLATE_USER": args.user,
        "TEMPLATE_PASS": args.password,
        "TEMPLATE_BOOT_MODE": args.boot_mode,
        "TEMPLATE_UEFI_TYPE": args.uefi_type,
        "TEMPLATE_DISK": args.target_disk,
    }

    for key, val in replacements.items():
        run_cmd(["sed", "-i", f"s/{key}/{val}/g", config_file])

    # 3. Hardware Scan
    print("📝 Generating hardware-configuration.nix...")
    sys_dir_full = os.path.join(dest_repo, f"systems/{args.host}")
    hw_config_path = os.path.join(sys_dir_full, "hardware-configuration.nix")

    try:
        hw_config_content = subprocess.check_output(
            ["nixos-generate-config", "--root", "/mnt", "--show-hardware-config"],
            text=True,
        )
        with open(hw_config_path, "w") as f:
            f.write(hw_config_content)
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to generate hardware config: {e}")
        sys.exit(1)


def finalize_install(host: str) -> None:
    """
    Commits local template changes and runs the installation.
    """
    # Note: We are already in /mnt/etc/nixos from generate_configs
    run_cmd(["git", "add", "."])
    run_cmd(["git", "config", "user.email", "install@nixos.local"])
    run_cmd(["git", "config", "user.name", "Installer"])
    # We commit the generated configs so the flake can see them (Nix flakes only see tracked files)
    run_cmd(["git", "commit", "-m", f"chore: bootstrap {host} configurations"])

    print(f"📦 Running nixos-install for {host}...")
    run_cmd(["nixos-install", "--flake", f".#{host}"])


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(description="NixOS One-Step Installer")
    parser.add_argument("host", help="Hostname for the new system")
    parser.add_argument("user", help="Primary username")
    parser.add_argument("password", help="Password for the user")
    parser.add_argument(
        "--repo",
        default="https://github.com/xiro-codes/dotfiles.v5.nix.git",
        help="Git repository URL to clone dotfiles from",
    )
    parser.add_argument("--disk", help="Manual disk override")
    parser.add_argument("--boot-mode", choices=["uefi", "bios"], default="uefi")
    parser.add_argument(
        "--uefi-type",
        choices=["systemd-boot", "grub", "limine"],
        default="systemd-boot",
    )
    args = parser.parse_args()

    target_disk = get_target_disk(args.disk)
    args.target_disk = target_disk

    print(f"\n🚀 Target: {target_disk} | Host: {args.host} | User: {args.user}")
    print(f"🔗 Repo: {args.repo}")
    if input("⚠️  Proceed with installation? (y/N): ").lower() != "y":
        sys.exit(0)

    # 1. Disk Setup
    boot_p = partition_and_format(target_disk)

    # 2. Mounting
    run_cmd(["mount", "/dev/disk/by-label/nixos", "/mnt"])
    os.makedirs("/mnt/boot", exist_ok=True)
    run_cmd(["mount", boot_p, "/mnt/boot"])

    # 3. Configuration & Clone
    generate_configs(args)

    # 4. Final Installation
    finalize_install(args.host)

    print("\n✅ Success! Rebooting in 10s...")
    time.sleep(10)
    run_cmd(["reboot"])


if __name__ == "__main__":
    main()
