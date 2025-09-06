#!/bin/bash

# NixOS Automatic Partitioning and Formatting Script
# Usage: ./partition-format.sh /dev/sda
# Creates: 1GB EFI boot, 4GB swap, remainder root (ext4)

set -e  # Exit on any error

# Configuration variables
readonly BOOT_SIZE="1025MiB"
readonly SWAP_SIZE="5121MiB"
readonly BOOT_LABEL="BOOT"
readonly SWAP_LABEL="SWAP"
readonly ROOT_LABEL="MAIN"

# Global variables
DISK=""
BOOT_PART=""
SWAP_PART=""
ROOT_PART=""

# Validation functions
validate_input() {
    local disk="$1"
    
    if [ -z "$disk" ]; then
        echo "Usage: $0 <disk_device>"
        echo "Example: $0 /dev/sda"
        exit 1
    fi

    if [ ! -b "$disk" ]; then
        echo "Error: $disk is not a valid block device"
        exit 1
    fi
    
    DISK="$disk"
}

confirm_destruction() {
    echo "WARNING: This will completely erase $DISK"
    echo "Press Enter to continue, or Ctrl+C to cancel"
    read
}

# Utility functions
get_partition_name() {
    local disk="$1"
    local num="$2"
    
    # Handle different naming schemes
    if [[ "$disk" =~ nvme|loop|mmcblk ]]; then
        echo "${disk}p${num}"
    else
        echo "${disk}${num}"
    fi
}

wait_for_partition() {
    local partition="$1"
    local timeout=30
    local count=0
    
    echo "Waiting for $partition to appear..."
    while [ ! -b "$partition" ] && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
    done
    
    if [ ! -b "$partition" ]; then
        echo "Error: Partition $partition did not appear after ${timeout}s"
        return 1
    fi
    
    echo "Partition $partition is ready"
    return 0
}

# Cleanup functions
cleanup_disk() {
    local disk="$1"
    echo "Cleaning up existing mounts and swaps on $disk..."
    
    # Get all partitions for this disk
    local partitions
    if [[ "$disk" =~ nvme|loop|mmcblk ]]; then
        partitions=$(lsblk -ln -o NAME "$disk" 2>/dev/null | tail -n +2 | sed "s|^|/dev/|" || true)
    else
        partitions=$(lsblk -ln -o NAME "$disk" 2>/dev/null | tail -n +2 | sed "s|^|/dev/|" || true)
    fi
    
    # Unmount and disable swap for existing partitions
    for partition in $partitions; do
        if [ -b "$partition" ]; then
            unmount_partition "$partition"
            disable_swap "$partition"
        fi
    done
}

unmount_partition() {
    local partition="$1"
    
    if mountpoint -q "$partition" 2>/dev/null; then
        echo "Unmounting $partition..."
        umount "$partition" 2>/dev/null || {
            echo "Warning: Failed to unmount $partition, trying force unmount..."
            umount -f "$partition" 2>/dev/null || {
                echo "Warning: Force unmount also failed for $partition"
            }
        }
    fi
}

disable_swap() {
    local partition="$1"
    
    if swapon --show=NAME --noheadings 2>/dev/null | grep -q "^$partition$"; then
        echo "Turning off swap on $partition..."
        swapoff "$partition" 2>/dev/null || {
            echo "Warning: Failed to turn off swap on $partition"
        }
    fi
}

cleanup_on_error() {
    echo "Error occurred, cleaning up..."
    [ -d "/mnt/boot" ] && umount /mnt/boot 2>/dev/null || true
    [ -d "/mnt" ] && mountpoint -q /mnt && umount /mnt 2>/dev/null || true
    [ -n "$SWAP_PART" ] && [ -b "$SWAP_PART" ] && swapoff "$SWAP_PART" 2>/dev/null || true
}

# Partitioning functions
clear_partition_table() {
    echo "Clearing existing partition table..."
    wipefs -a "$DISK"
    
    echo "Creating GPT partition table..."
    parted "$DISK" --script mklabel gpt
}

create_partitions() {
    echo "Creating EFI boot partition..."
    parted "$DISK" --script mkpart primary fat32 1MiB "$BOOT_SIZE"
    parted "$DISK" --script set 1 esp on

    echo "Creating swap partition..."
    parted "$DISK" --script mkpart primary linux-swap "$BOOT_SIZE" "$SWAP_SIZE"

    echo "Creating root partition..."
    parted "$DISK" --script mkpart primary ext4 "$SWAP_SIZE" 100%
}

update_partition_table() {
    echo "Updating partition table..."
    partprobe "$DISK"
    udevadm settle
}

verify_partitions() {
    local expected_count=3
    
    echo "Verifying partition creation..."
    sleep 3
    
    local actual_count=$(lsblk -ln "$DISK" 2>/dev/null | tail -n +2 | wc -l)
    if [ "$actual_count" -ne "$expected_count" ]; then
        echo "Error: Expected $expected_count partitions, found $actual_count"
        return 1
    fi
    
    echo "Partition verification successful"
    return 0
}

set_partition_variables() {
    BOOT_PART=$(get_partition_name "$DISK" 1)
    SWAP_PART=$(get_partition_name "$DISK" 2)
    ROOT_PART=$(get_partition_name "$DISK" 3)
}

wait_for_all_partitions() {
    wait_for_partition "$BOOT_PART"
    wait_for_partition "$SWAP_PART"
    wait_for_partition "$ROOT_PART"
}

# Formatting functions
format_boot_partition() {
    echo "Formatting EFI boot partition..."
    if ! mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"; then
        echo "Error: Failed to format boot partition"
        return 1
    fi
}

format_swap_partition() {
    echo "Setting up swap partition..."
    if ! mkswap -L "$SWAP_LABEL" "$SWAP_PART"; then
        echo "Error: Failed to create swap"
        return 1
    fi
}

format_root_partition() {
    echo "Formatting root partition..."
    if ! mkfs.ext4 -F -L "$ROOT_LABEL" "$ROOT_PART"; then
        echo "Error: Failed to format root partition"
        return 1
    fi
}

format_all_partitions() {
    format_boot_partition || return 1
    format_swap_partition || return 1
    format_root_partition || return 1
}

# Mounting functions
mount_root_filesystem() {
    echo "Mounting root filesystem..."
    if ! mount "$ROOT_PART" /mnt; then
        echo "Error: Failed to mount root partition"
        return 1
    fi
}

mount_boot_filesystem() {
    echo "Creating and mounting boot directory..."
    mkdir -p /mnt/boot
    if ! mount "$BOOT_PART" /mnt/boot; then
        echo "Error: Failed to mount boot partition"
        return 1
    fi
}

enable_swap() {
    echo "Enabling swap..."
    if ! swapon "$SWAP_PART"; then
        echo "Error: Failed to enable swap"
        return 1
    fi
}

mount_all_filesystems() {
    mount_root_filesystem || return 1
    mount_boot_filesystem || return 1
    enable_swap || return 1
}

# Status and reporting functions
display_completion_status() {
    echo "Partitioning and formatting complete!"
    echo
    echo "Partition layout:"
    lsblk "$DISK"
    echo
    echo "Mounted filesystems:"
    df -h /mnt /mnt/boot
    echo
    echo "Swap status:"
    swapon --show
    echo
    echo "Ready for: nixos-generate-config --root /mnt"
    echo "Labels created: $BOOT_LABEL, $SWAP_LABEL, $ROOT_LABEL (matching your hardware-configuration.nix)"
}

# Main execution function
main() {
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Check system requirements
    check_required_commands
    
    # Validation phase
    validate_input "$1"
    confirm_destruction
    
    # Cleanup phase
    cleanup_disk "$DISK"
    
    # Partitioning phase
    clear_partition_table
    create_partitions
    update_partition_table
    verify_partitions
    
    # Partition setup phase
    set_partition_variables
    wait_for_all_partitions
    
    # Formatting phase
    format_all_partitions
    
    # Mounting phase
    mount_all_filesystems
    
    # Completion
    display_completion_status
}

# Script entry point
main "$@"
