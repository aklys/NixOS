#!/bin/bash

# NixOS Automatic Partitioning and Formatting Script
# Usage: ./partition-format.sh /dev/sda
# Creates: 1GB EFI boot, 4GB swap, remainder root (ext4)

set -e  # Exit on any error

DISK="$1"

# Validate input
if [ -z "$DISK" ]; then
    echo "Usage: $0 <disk_device>"
    echo "Example: $0 /dev/sda"
    exit 1
fi

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a valid block device"
    exit 1
fi

echo "WARNING: This will completely erase $DISK"
echo "Press Enter to continue, or Ctrl+C to cancel"
read

# Unmount any existing partitions on this disk
echo "Unmounting any existing partitions..."
for partition in ${DISK}*; do
    if [ -b "$partition" ]; then
        umount "$partition" 2>/dev/null || true
        swapoff "$partition" 2>/dev/null || true
    fi
done

# Clear existing partition table and create GPT
echo "Clearing existing partition table..."
wipefs -a "$DISK"

echo "Creating GPT partition table..."
parted "$DISK" --script mklabel gpt

# Create EFI system partition (1GB)
echo "Creating EFI boot partition..."
parted "$DISK" --script mkpart primary fat32 1MiB 1025MiB
parted "$DISK" --script set 1 esp on

# Create swap partition (4GB) 
echo "Creating swap partition..."
parted "$DISK" --script mkpart primary linux-swap 1025MiB 5121MiB

# Create root partition (remainder)
echo "Creating root partition..."
parted "$DISK" --script mkpart primary ext4 5121MiB 100%

# Wait for kernel to update partition table
sleep 2
partprobe "$DISK"
sleep 2

# Define partition devices
BOOT_PART="${DISK}1"
SWAP_PART="${DISK}2"
ROOT_PART="${DISK}3"

# Format partitions
echo "Formatting EFI boot partition..."
mkfs.fat -F 32 -n BOOT "$BOOT_PART"

echo "Setting up swap partition..."
mkswap -L SWAP "$SWAP_PART"

echo "Formatting root partition..."
mkfs.ext4 -L MAIN "$ROOT_PART"

# Mount filesystems
echo "Mounting filesystems..."
mount "$ROOT_PART" /mnt

mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

swapon "$SWAP_PART"

echo "Partitioning and formatting complete!"
echo
echo "Partition layout:"
lsblk "$DISK"
echo
echo "Mounted filesystems:"
df -h | grep -E "(${ROOT_PART}|${BOOT_PART})"
echo
echo "Ready for nixos-generate-config --root /mnt"
