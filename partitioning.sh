#!/bin/bash

# NixOS Disk Preparation Script
# Usage: ./partition-format.sh /dev/sda

set -e

# Configuration
readonly REQUIRED_COMMANDS=("parted" "mkfs.fat" "mkfs.ext4" "mkswap" "lsblk" "umount" "swapon" "swapoff" "mountpoint")
readonly BOOT_LABEL="BOOT"
readonly SWAP_LABEL="SWAP" 
readonly ROOT_LABEL="MAIN"

# Global variables
DISK=""
BOOT_PART=""
SWAP_PART=""
ROOT_PART=""

check_commands() {
    local missing=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo "Error: Missing commands: ${missing[*]}"
        exit 1
    fi
}

validate_input() {
    [ -z "$1" ] && { echo "Usage: $0 /dev/sdX"; exit 1; }
    [ ! -b "$1" ] && { echo "Error: $1 not found"; exit 1; }
    DISK="$1"
}

confirm_destruction() {
    echo "WARNING: This will erase $DISK"
    echo "Press Enter to continue or Ctrl+C to cancel"
    read
}

cleanup_existing_partitions() {
    echo "Cleaning up existing partitions..."
    for part in $(lsblk -rno NAME "$DISK" 2>/dev/null | tail -n +2 | sed "s|^|/dev/|"); do
        mountpoint -q "$part" 2>/dev/null && umount "$part" 2>/dev/null || true
        swapon --show=NAME --noheadings 2>/dev/null | grep -q "^$part$" && swapoff "$part" 2>/dev/null || true
    done
}

get_partition_name() {
    local disk="$1" num="$2"
    [[ "$disk" =~ (nvme|mmcblk|loop) ]] && echo "${disk}p${num}" || echo "${disk}${num}"
}

create_partitions() {
    echo "Creating partitions..."
    parted "$DISK" --script mklabel gpt
    parted "$DISK" --script mkpart primary fat32 1MiB 1025MiB
    parted "$DISK" --script set 1 esp on
    parted "$DISK" --script mkpart primary linux-swap 1025MiB 5121MiB
    parted "$DISK" --script mkpart primary ext4 5121MiB 100%
}

set_partition_variables() {
    BOOT_PART=$(get_partition_name "$DISK" 1)
    SWAP_PART=$(get_partition_name "$DISK" 2)
    ROOT_PART=$(get_partition_name "$DISK" 3)
}

wait_for_partitions() {
    sleep 2
}

format_partitions() {
    echo "Formatting partitions..."
    mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"
    mkswap -L "$SWAP_LABEL" "$SWAP_PART"
    mkfs.ext4 -F -L "$ROOT_LABEL" "$ROOT_PART"
}

show_results() {
    echo "Complete. Partitions ready:"
    lsblk -f "$DISK"
}

main() {
    check_commands
    validate_input "$1"
    confirm_destruction
    cleanup_existing_partitions
    create_partitions
    set_partition_variables
    wait_for_partitions
    format_partitions
    show_results
}

main "$@"
