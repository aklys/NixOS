#!/bin/bash

# NixOS Automatic Partitioning and Formatting Script
# Usage: ./partition-format.sh /dev/sda
# Creates: 1GB EFI boot, 4GB swap, remainder root (ext4)

set -e  # Exit on any error

DISK="$1"
BOOT_SIZE="1G"
SWAP_SIZE="4G"

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

# Clear existing partition table
echo "Clearing existing partition table..."
sgdisk --zap-all "$DISK"

# Create GPT partition table and partitions
echo "Creating partitions..."
sgdisk \
    --new=1:0:+${BOOT_SIZE} --typecode=1:ef00 --change-name=1:"EFI System" \
    --new=2:0:+${SWAP_SIZE} --typecode=2:8200 --change-name=2:"Linux swap" \
    --new=3:0:0 --typecode=3:8300 --change-name=3:"Linux filesystem" \
    "$DISK"

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
mkswap -L swap "$SWAP_PART"

echo "Formatting root partition..."
mkfs.ext4 -L nixos "$ROOT_PART"

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
