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

# Required commands for this script
readonly REQUIRED_COMMANDS=(
    "parted"
    "mkfs.fat"
    "mkfs.ext4" 
    "mkswap"
    "mount"
    "umount"
    "swapon"
    "swapoff"
    "lsblk"
    "wipefs"
    "partprobe"
    "udevadm"
    "mountpoint"
)

# Global variables
DISK=""
BOOT_PART=""
SWAP_PART=""
ROOT_PART=""

# Check for required commands
check_required_commands() {
    local missing_commands=()
    
    echo "Checking for required commands..."
    
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        echo "Error: The following required commands are missing:"
        printf '%s\n' "${missing_commands[@]}"
        echo
        echo "Please install the missing packages:"
        echo "- parted (for partitioning)"
        echo "- dosfstools (for mkfs.fat)"
        echo "- e2fsprogs (for mkfs.ext4)"
        echo "- util-linux (for mkswap, mount, swapon, lsblk, etc.)"
        echo "- udev (for udevadm, partprobe)"
        exit 1
    fi
    
    echo "All required commands are available"
}

# Validate input
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

# Confirm destruction
confirm_destruction() {
    echo "WARNING: This will completely erase $DISK"
    echo "Press Enter to continue, or Ctrl+C to cancel"
    read
}

# Get correct partition name for different disk types
get_partition_name() {
    local disk="$1"
    local num="$2"
    
    # Handle different naming schemes
    if [[ "$disk" =~ (nvme|loop|mmcblk) ]]; then
        echo "${disk}p${num}"
    else
        echo "${disk}${num}"
    fi
}

# Wait for partition to appear
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
}

# Unmount partition if mounted
unmount_partition() {
    local partition="$1"
    
    if [ -b "$partition" ] && mountpoint -q "$partition" 2>/dev/null; then
        echo "Unmounting $partition..."
        if ! umount "$partition" 2>/dev/null; then
            echo "Warning: Normal unmount failed, trying force unmount..."
            umount -f "$partition" 2>/dev/null || echo "Warning: Force unmount also failed for $partition"
        fi
    fi
}

# Disable swap if active
disable_swap() {
    local partition="$1"
    
    if [ -b "$partition" ] && swapon --show=NAME --noheadings 2>/dev/null | grep -q "^$partition$"; then
        echo "Turning off swap on $partition..."
        swapoff "$partition" 2>/dev/null || echo "Warning: Failed to turn off swap on $partition"
    fi
}

# Clean up existing partitions on disk
cleanup_disk() {
    local disk="$1"
    echo "Cleaning up existing mounts and swaps on $disk..."
    
    # Get partition names - use lsblk to get actual partition names
    local partitions
    partitions=$(lsblk -rno NAME "$disk" 2>/dev/null | tail -n +2 | sed 's|^|/dev/|' || true)
    
    # Process each partition
    for partition in $partitions; do
        if [ -b "$partition" ]; then
            unmount_partition "$partition"
            disable_swap "$partition"
        fi
    done
}

# Cleanup on error
cleanup_on_error() {
    echo "Error occurred, cleaning up..."
    
    # Unmount boot if mounted
    if mountpoint -q /mnt/boot 2>/dev/null; then
        umount /mnt/boot 2>/dev/null || true
    fi
    
    # Unmount root if mounted  
    if mountpoint -q /mnt 2>/dev/null; then
        umount /mnt 2>/dev/null || true
    fi
    
    # Turn off swap if active
    if [ -n "$SWAP_PART" ] && [ -b "$SWAP_PART" ]; then
        swapoff "$SWAP_PART" 2>/dev/null || true
    fi
}

# Clear partition table
clear_partition_table() {
    echo "Clearing existing partition table..."
    wipefs -a "$DISK"
    
    echo "Creating GPT partition table..."
    parted "$DISK" --script mklabel gpt
}

# Create partitions
create_partitions() {
    echo "Creating EFI boot partition..."
    parted "$DISK" --script mkpart primary fat32 1MiB "$BOOT_SIZE"
    parted "$DISK" --script set 1 esp on

    echo "Creating swap partition..."
    parted "$DISK" --script mkpart primary linux-swap "$BOOT_SIZE" "$SWAP_SIZE"

    echo "Creating root partition..."
    parted "$DISK" --script mkpart primary ext4 "$SWAP_SIZE" 100%
}

# Update partition table
update_partition_table() {
    echo "Updating partition table..."
    partprobe "$DISK"
    udevadm settle
}

# Verify partitions were created
verify_partitions() {
    echo "Verifying partition creation..."
    sleep 3
    
    # Check that we have exactly 3 partitions
    local partition_count
    partition_count=$(lsblk -rno TYPE "$DISK" 2>/dev/null | grep -c "part" || echo "0")
    
    if [ "$partition_count" -ne 3 ]; then
        echo "Error: Expected 3 partitions, found $partition_count"
        return 1
    fi
    
    echo "Partition verification successful"
}

# Set partition variables
set_partition_variables() {
    BOOT_PART=$(get_partition_name "$DISK" 1)
    SWAP_PART=$(get_partition_name "$DISK" 2)
    ROOT_PART=$(get_partition_name "$DISK" 3)
}

# Wait for all partitions
wait_for_all_partitions() {
    wait_for_partition "$BOOT_PART"
    wait_for_partition "$SWAP_PART"
    wait_for_partition "$ROOT_PART"
}

# Format boot partition
format_boot_partition() {
    echo "Formatting EFI boot partition..."
    if ! mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"; then
        echo "Error: Failed to format boot partition"
        return 1
    fi
}

# Format swap partition
format_swap_partition() {
    echo "Setting up swap partition..."
    if ! mkswap -L "$SWAP_LABEL" "$SWAP_PART"; then
        echo "Error: Failed to create swap"
        return 1
    fi
}

# Format root partition
format_root_partition() {
    echo "Formatting root partition..."
    if ! mkfs.ext4 -F -L "$ROOT_LABEL" "$ROOT_PART"; then
        echo "Error: Failed to format root partition"
        return 1
    fi
}

# Format all partitions
format_all_partitions() {
    format_boot_partition || return 1
    format_swap_partition || return 1
    format_root_partition || return 1
}

# Mount root filesystem
mount_root_filesystem() {
    echo "Mounting root filesystem..."
    if ! mount "$ROOT_PART" /mnt; then
        echo "Error: Failed to mount root partition"
        return 1
    fi
}

# Mount boot filesystem
mount_boot_filesystem() {
    echo "Creating and mounting boot directory..."
    mkdir -p /mnt/boot
    if ! mount "$BOOT_PART" /mnt/boot; then
        echo "Error: Failed to mount boot partition"
        return 1
    fi
}

# Enable swap
enable_swap() {
    echo "Enabling swap..."
    if ! swapon "$SWAP_PART"; then
        echo "Error: Failed to enable swap"
        return 1
    fi
}

# Mount all filesystems
mount_all_filesystems() {
    mount_root_filesystem || return 1
    mount_boot_filesystem || return 1
    enable_swap || return 1
}

# Display completion status
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

# Main function
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
