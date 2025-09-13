#!/usr/bin/env bash

# NixOS Disk Preparation Script
# Purpose: Prepare disk for NixOS installation by creating labeled partitions
# Usage: ./partition-format.sh /dev/sdX
# Creates: 1GB EFI boot (BOOT), 4GB swap (SWAP), remainder root (MAIN)

set -euo pipefail

# Configuration
readonly REQUIRED_COMMANDS=("parted" "mkfs.fat" "mkfs.ext4" "mkswap" "lsblk" "umount" "swapoff" "mountpoint" "wipefs")
readonly BOOT_SIZE="1025MiB"
readonly SWAP_SIZE="5121MiB"
readonly BOOT_LABEL="BOOT"
readonly SWAP_LABEL="SWAP"
readonly ROOT_LABEL="MAIN"

DISK=""

check_requirements() {
    local missing=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        command -v "$cmd" >/dev/null || missing+=("$cmd")
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing commands: ${missing[*]}"
        exit 1
    fi
}

confirm_operation() {
    echo "WARNING: This will destroy all data on $DISK"
    echo "Type 'yes' to continue:"
    read -r response
    [ "$response" = "yes" ] || { echo "Cancelled"; exit 1; }
}

cleanup_disk() {
    echo "Cleaning up $DISK..."
    
    # Unmount any mounted partitions and disable swap
    while IFS= read -r partition; do
        [ -b "$partition" ] || continue
        mountpoint -q "$partition" 2>/dev/null && umount "$partition"
        swapoff "$partition" 2>/dev/null || true
    done < <(lsblk -rno NAME "$DISK" 2>/dev/null | tail -n +2 | sed "s|^|/dev/|")
    
    # Clean installation mountpoints if they exist
    for mount in /mnt/boot /mnt; do
        mountpoint -q "$mount" 2>/dev/null && umount "$mount"
    done
    
    # Wipe all signatures
    wipefs -af "$DISK" >/dev/null
}

get_partition_name() {
    local num="$1"
    [[ "$DISK" =~ (nvme|mmcblk|loop) ]] && echo "${DISK}p${num}" || echo "${DISK}${num}"
}

create_partitions() {
    echo "Creating partitions..."
    
    parted "$DISK" --script \
        mklabel gpt \
        mkpart primary fat32 1MiB "$BOOT_SIZE" \
        set 1 esp on \
        mkpart primary linux-swap "$BOOT_SIZE" "$SWAP_SIZE" \
        mkpart primary ext4 "$SWAP_SIZE" 100%
    
    # Verify partitions exist
    local boot_part swap_part root_part
    boot_part=$(get_partition_name 1)
    swap_part=$(get_partition_name 2)
    root_part=$(get_partition_name 3)
    
    for part in "$boot_part" "$swap_part" "$root_part"; do
        [ -b "$part" ] || { echo "Error: Partition $part not created"; exit 1; }
    done
}

format_partitions() {
    echo "Formatting partitions..."
    
    local boot_part swap_part root_part
    boot_part=$(get_partition_name 1)
    swap_part=$(get_partition_name 2)
    root_part=$(get_partition_name 3)
    
    mkfs.fat -F 32 -n "$BOOT_LABEL" "$boot_part" >/dev/null
    mkswap -L "$SWAP_LABEL" "$swap_part" >/dev/null
    mkfs.ext4 -F -L "$ROOT_LABEL" "$root_part" >/dev/null
}

show_results() {
    echo -e "\nComplete. Partition layout:"
    lsblk "$DISK" -o NAME,SIZE,TYPE,FSTYPE,LABEL
    echo -e "\nReady for: nixos-generate-config --root /mnt"
}

main() {
    [ $# -eq 1 ] || { echo "Usage: $0 /dev/sdX"; exit 1; }
    [ -b "$1" ] || { echo "Error: $1 is not a block device"; exit 1; }
    
    DISK="$1"
    
    check_requirements
    confirm_operation
    cleanup_disk
    create_partitions
    format_partitions
    show_results
}

main "$@"
