#!/bin/bash

# NixOS Disk Preparation Script
# Purpose: Prepare disk for NixOS installation by creating labeled partitions
# Usage: ./partition-format.sh /dev/sdX
# Creates: 1GB EFI boot (BOOT), 4GB swap (SWAP), remainder root (MAIN)

set -e

# Configuration variables
readonly REQUIRED_COMMANDS=("parted" "mkfs.fat" "mkfs.ext4" "mkswap" "lsblk" "umount" "swapon" "swapoff" "mountpoint" "wipefs")
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

# 7. Check required commands are available
check_required_commands() {
    local missing=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo "Error: Missing required commands: ${missing[*]}"
        echo "Install required packages and try again"
        exit 1
    fi
}

# 2. Get user confirmation for destructive operation
confirm_destruction() {
    echo "This will destroy all data on $DISK and prepare it for NixOS installation"
    echo "Type 'yes' to continue:"
    read -r response
    
    if [ "$response" != "yes" ]; then
        echo "Operation cancelled"
        exit 1
    fi
}

# 3. Unmount all partitions for target device
unmount_all_partitions() {
    echo "Unmounting partitions on $DISK..."
    
    # Get all partitions for this disk
    local partitions
    partitions=$(lsblk -rno NAME "$DISK" 2>/dev/null | tail -n +2 | sed "s|^|/dev/|" || true)
    
    # Unmount in reverse order (boot before root)
    mountpoint -q /mnt/boot 2>/dev/null && { umount /mnt/boot || { echo "Error: Failed to unmount /mnt/boot"; exit 1; }; }
    mountpoint -q /mnt 2>/dev/null && { umount /mnt || { echo "Error: Failed to unmount /mnt"; exit 1; }; }
    
    # Unmount any other mounts and disable swap
    for part in $partitions; do
        if mountpoint -q "$part" 2>/dev/null; then
            umount "$part" || { echo "Error: Failed to unmount $part"; exit 1; }
        fi
        if swapon --show=NAME --noheadings 2>/dev/null | grep -q "^$part$"; then
            swapoff "$part" || { echo "Error: Failed to disable swap on $part"; exit 1; }
        fi
    done
}

# 4. Remove all partitions from device
remove_all_partitions() {
    echo "Removing existing partitions from $DISK..."
    
    # Wipe filesystem signatures and partition table
    wipefs -a "$DISK" || { echo "Error: Failed to wipe $DISK"; exit 1; }
}

# Helper function for partition naming
get_partition_name() {
    local disk="$1" num="$2"
    if [[ "$disk" =~ (nvme|mmcblk|loop) ]]; then
        echo "${disk}p${num}"
    else
        echo "${disk}${num}"
    fi
}

# 5a. Create partition table and partitions
create_partitions() {
    echo "Creating new partition table and partitions..."
    
    # Create GPT partition table
    parted "$DISK" --script mklabel gpt || { echo "Error: Failed to create partition table"; exit 1; }
    
    # Create EFI boot partition
    parted "$DISK" --script mkpart primary fat32 1MiB "$BOOT_SIZE" || { echo "Error: Failed to create boot partition"; exit 1; }
    parted "$DISK" --script set 1 esp on || { echo "Error: Failed to set ESP flag"; exit 1; }
    
    # Create swap partition  
    parted "$DISK" --script mkpart primary linux-swap "$BOOT_SIZE" "$SWAP_SIZE" || { echo "Error: Failed to create swap partition"; exit 1; }
    
    # Create root partition
    parted "$DISK" --script mkpart primary ext4 "$SWAP_SIZE" 100% || { echo "Error: Failed to create root partition"; exit 1; }
    
    # Set partition variables
    BOOT_PART=$(get_partition_name "$DISK" 1)
    SWAP_PART=$(get_partition_name "$DISK" 2)  
    ROOT_PART=$(get_partition_name "$DISK" 3)
    
    # Wait for kernel to recognize partitions
    sleep 2
}

# 5b. Format partitions with labels
format_partitions() {
    echo "Formatting partitions with labels..."
    
    # Format boot partition
    mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART" || { echo "Error: Failed to format boot partition"; exit 1; }
    
    # Format swap partition
    mkswap -L "$SWAP_LABEL" "$SWAP_PART" || { echo "Error: Failed to format swap partition"; exit 1; }
    
    # Format root partition  
    mkfs.ext4 -F -L "$ROOT_LABEL" "$ROOT_PART" || { echo "Error: Failed to format root partition"; exit 1; }
}

# 6. Display final results for validation
display_results() {
    echo ""
    echo "Complete. Partition layout:"
    lsblk "$DISK" -o NAME,SIZE,TYPE,FSTYPE,LABEL
    echo ""
    echo "Ready for nixos-generate-config --root /mnt"
}

# 9. Main execution function
main() {
    # Validate arguments
    if [ -z "$1" ]; then
        echo "Usage: $0 /dev/sdX"
        exit 1
    fi
    
    if [ ! -b "$1" ]; then
        echo "Error: $1 is not a valid block device"
        exit 1
    fi
    
    DISK="$1"
    
    # Execute in order
    check_required_commands
    confirm_destruction
    unmount_all_partitions
    remove_all_partitions
    create_partitions
    format_partitions
    display_results
}

main "$@"
