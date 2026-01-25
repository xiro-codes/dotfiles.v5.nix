#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import time
import argparse


def run_cmd(cmd, cwd=None):
    """Executes a system command and handles failure."""
    try:
        subprocess.run(cmd, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Command failed: {' '.join(cmd)}")
        sys.exit(1)


def get_target_disk(override=None):
    """Detects the best disk or uses the provided override."""
    if override:
        return override

    lsblk = subprocess.check_output(["lsblk", "-dno", "NAME,TYPE"], text=True)
    for priority in ["nvme", "vd", "sd"]:
        for line in lsblk.splitlines():
            if priority in line and "disk" in line:
                return f"/dev/{line.split()[0]}"

    print("❌ No disk detected!")
    sys.exit(1)


def partition_and_format(disk):
    """Wipes disk and creates partitions."""
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


def generate_configs(args):
    """Copies files and populates templates."""
    src_repo = "/etc/dotfiles-src"
    dest_repo = "/mnt/etc/dotfiles"

    print("📂 Copying files to /etc/dotfiles...")
    os.makedirs("/mnt/etc", exist_ok=True)

    # Copy files while ignoring the existing .git folder to keep it clean
    shutil.copytree(
        src_repo, dest_repo, dirs_exist_ok=True, ignore=shutil.ignore_patterns(".git")
    )

    os.chdir(dest_repo)

    # 1. Home Configuration
    with open("templates/host-home.nix", "r") as f:
        content = (
            f.read()
            .replace("TEMPLATE_USER", args.user)
            .replace("TEMPLATE_DESKTOP", args.desktop)
        )
    with open(f"home/{args.user}@{args.host}.nix", "w") as f:
        f.write(content)

    # 2. System Configuration
    sys_dir = f"systems/{args.host}"
    os.makedirs(sys_dir, exist_ok=True)
    with open("templates/host-system.nix", "r") as f:
        content = (
            f.read()
            .replace("TEMPLATE_USER", args.user)
            .replace("TEMPLATE_DESKTOP", args.desktop)
            .replace("TEMPLATE_PASS", args.password)
            .replace("TEMPLATE_BOOT_MODE", args.boot_mode)
            .replace("TEMPLATE_UEFI_TYPE", args.uefi_type)
            .replace("TEMPLATE_DISK", args.target_disk)
        )
    with open(f"{sys_dir}/configuration.nix", "w") as f:
        f.write(content)

    # 3. FIXED: Hardware Scan using stdout redirection
    print("📝 Generating hardware-configuration.nix...")
    hw_config_path = f"{sys_dir}/hardware-configuration.nix"

    # We use subprocess.check_output to capture the stdout of the config generator
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


def finalize_install(host):
    """Initializes a clean Git repo and installs."""
    # Initialize fresh git so the flake can be read
    run_cmd(["git", "init"])
    run_cmd(["git", "add", "."])
    run_cmd(["git", "config", "user.email", "install@nixos.local"])
    run_cmd(["git", "config", "user.name", "Installer"])
    run_cmd(["git", "commit", "-m", f"Initial bootstrap for {host}"])

    run_cmd(["nixos-install", "--flake", f".#{host}"])


def main():
    parser = argparse.ArgumentParser(description="NixOS One-Step Installer")
    parser.add_argument("host", help="Hostname")
    parser.add_argument("desktop", help="Desktop Environment")
    parser.add_argument("user", help="Username")
    parser.add_argument("password", help="Password")
    parser.add_argument("--disk", help="Disk override")
    parser.add_argument("--boot-mode", choices=["uefi", "bios"], default="uefi")
    parser.add_argument(
        "--uefi-type",
        choices=["systemd-boot", "grub", "limine"],
        default="systemd-boot",
    )
    args = parser.parse_args()

    target_disk = get_target_disk(args.disk)

    # Simple Summary
    print(f"\n🚀 Target: {target_disk} | Host: {args.host} | User: {args.user}")
    if input("⚠️  Proceed? (y/N): ").lower() != "y":
        sys.exit(0)

    boot_p = partition_and_format(target_disk)

    # Mount
    run_cmd(["mount", "/dev/disk/by-label/nixos", "/mnt"])
    os.makedirs("/mnt/boot", exist_ok=True)
    run_cmd(["mount", boot_p, "/mnt/boot"])

    generate_configs(args)
    finalize_install(args.host)

    print("\n✅ Success! Rebooting in 10s...")
    time.sleep(10)
    run_cmd(["reboot"])


if __name__ == "__main__":
    main()
