#!/bin/bash

# NixOS Complete Installation Script
# Purpose: Automate full NixOS installation from partition to bootable system
# Usage: ./install-nixos.sh /dev/sdX [config-source-path]
# Requirements: Run from NixOS installation ISO

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PARTITION_SCRIPT="$SCRIPT_DIR/partition-prep.sh"
readonly CONFIG_DEFAULT_PATH="/tmp/nixos-config"
readonly MOUNT_ROOT="/mnt"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
DISK=""
CONFIG_SOURCE=""

log() {
    local level="$1"
    shift
    case "$level" in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $*" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $*" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
    esac
}

cleanup_on_error() {
    log "WARN" "Installation failed, cleaning up..."
    swapoff /dev/disk/by-label/SWAP 2>/dev/null || true
    umount "$MOUNT_ROOT/boot" 2>/dev/null || true  
    umount "$MOUNT_ROOT" 2>/dev/null || true
}

check_environment() {
    log "INFO" "Checking environment..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "Must run as root. Use: sudo $0"
        exit 1
    fi
    
    # Check if running from NixOS ISO
    if ! command -v nixos-install >/dev/null 2>&1; then
        log "ERROR" "nixos-install not found. Are you running from NixOS installation ISO?"
        exit 1
    fi
    
    # Check for partition script
    if [ ! -f "$PARTITION_SCRIPT" ]; then
        log "ERROR" "Partition script not found at: $PARTITION_SCRIPT"
        log "INFO" "Ensure partition-prep.sh is in the same directory as this script"
        exit 1
    fi
    
    log "SUCCESS" "Environment check passed"
}

validate_disk() {
    local disk="$1"
    
    if [ ! -b "$disk" ]; then
        log "ERROR" "$disk is not a valid block device"
        exit 1
    fi
    
    # Show disk information
    log "INFO" "Target disk information:"
    lsblk "$disk" -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    echo
}

prepare_disk() {
    log "INFO" "Starting disk preparation..."
    
    # Make partition script executable
    chmod +x "$PARTITION_SCRIPT"
    
    # Run partition script
    if "$PARTITION_SCRIPT" "$DISK"; then
        log "SUCCESS" "Disk partitioning completed"
    else
        log "ERROR" "Disk partitioning failed"
        exit 1
    fi
    
    # Verify partitions were created
    log "INFO" "Verifying partitions..."
    for label in MAIN BOOT SWAP; do
        if [ ! -e "/dev/disk/by-label/$label" ]; then
            log "ERROR" "Partition with label $label not found"
            exit 1
        fi
    done
    log "SUCCESS" "All partitions verified"
}

mount_filesystems() {
    log "INFO" "Mounting filesystems..."
    
    # Mount root if not already mounted
    if ! mountpoint -q "$MOUNT_ROOT"; then
        mount /dev/disk/by-label/MAIN "$MOUNT_ROOT" || {
            log "ERROR" "Failed to mount root filesystem"
            exit 1
        }
    fi
    
    # Create boot directory and mount if not already mounted
    mkdir -p "$MOUNT_ROOT/boot"
    if ! mountpoint -q "$MOUNT_ROOT/boot"; then
        mount /dev/disk/by-label/BOOT "$MOUNT_ROOT/boot" || {
            log "ERROR" "Failed to mount boot filesystem"
            exit 1
        }
    fi
    
    # Enable swap if not already active
    if ! swapon --show=NAME --noheadings | grep -q "^/dev/disk/by-label/SWAP$"; then
        swapon /dev/disk/by-label/SWAP || {
            log "ERROR" "Failed to enable swap"
            exit 1
        }
    fi
    
    log "SUCCESS" "Filesystems mounted successfully"
    log "INFO" "Mount status:"
    df -h "$MOUNT_ROOT" "$MOUNT_ROOT/boot"
    swapon --show
}

deploy_configuration() {
    log "INFO" "Deploying NixOS configuration..."
    
    # Create nixos config directory
    mkdir -p "$MOUNT_ROOT/etc/nixos"
    
    if [ -d "$CONFIG_SOURCE" ]; then
        # Copy existing configuration
        log "INFO" "Copying configuration from: $CONFIG_SOURCE"
        cp -r "$CONFIG_SOURCE"/* "$MOUNT_ROOT/etc/nixos/" || {
            log "ERROR" "Failed to copy configuration files"
            exit 1
        }
    else
        # Generate minimal configuration
        log "INFO" "Generating minimal configuration..."
        nixos-generate-config --root "$MOUNT_ROOT" || {
            log "ERROR" "Failed to generate configuration"
            exit 1
        }
        
        log "WARN" "Using generated configuration - you may need to customize it"
    fi
    
    # Verify essential files exist
    for file in "configuration.nix" "hardware-configuration.nix"; do
        if [ ! -f "$MOUNT_ROOT/etc/nixos/$file" ]; then
            log "ERROR" "Required file missing: $file"
            exit 1
        fi
    done
    
    log "SUCCESS" "Configuration deployed"
}

install_system() {
    log "INFO" "Starting NixOS installation..."
    log "INFO" "This may take several minutes..."
    
    if nixos-install --root "$MOUNT_ROOT"; then
        log "SUCCESS" "NixOS installation completed"
    else
        log "ERROR" "NixOS installation failed"
        exit 1
    fi
}

show_post_install_tasks() {
    log "SUCCESS" "Installation completed successfully!"
    echo
    log "INFO" "POST-INSTALLATION TASKS:"
    log "INFO" "After rebooting, you will need to:"
    log "INFO" "1. Log in as root with the password you set"
    log "INFO" "2. Set passwords for any user accounts defined in your configuration"
    echo
}

cleanup_and_finish() {
    log "INFO" "Cleaning up..."
    
    # Disable swap
    swapoff /dev/disk/by-label/SWAP || log "WARN" "Failed to disable swap"
    
    # Unmount filesystems
    umount "$MOUNT_ROOT/boot" || log "WARN" "Failed to unmount boot"
    umount "$MOUNT_ROOT" || log "WARN" "Failed to unmount root"
    
    show_post_install_tasks
    
    read -p "Reboot now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "INFO" "Rebooting..."
        reboot
    fi
}

show_usage() {
    cat << EOF
Usage: $0 /dev/sdX [config-source-path]

Arguments:
  /dev/sdX              Target disk for installation
  config-source-path    Optional path to existing NixOS configuration
                        If not provided, will generate minimal config

Examples:
  $0 /dev/sda
  $0 /dev/nvme0n1 /home/user/nixos-config
  $0 /dev/sda /mnt/usb/nixos-configs

Requirements:
- Must be run from NixOS installation ISO
- partition-prep.sh must be in same directory
- Run as root (use sudo)
EOF
}

main() {
    # Parse arguments
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        show_usage
        exit 1
    fi
    
    DISK="$1"
    CONFIG_SOURCE="${2:-}"
    
    # Show banner
    echo
    log "INFO" "NixOS Complete Installation Script"
    log "INFO" "Target disk: $DISK"
    [ -n "$CONFIG_SOURCE" ] && log "INFO" "Config source: $CONFIG_SOURCE"
    echo
    
    # Validate inputs
    check_environment
    validate_disk "$DISK"
    
    if [ -n "$CONFIG_SOURCE" ] && [ ! -d "$CONFIG_SOURCE" ]; then
        log "ERROR" "Configuration source directory not found: $CONFIG_SOURCE"
        exit 1
    fi
    
    # Execute installation steps
    prepare_disk
    mount_filesystems
    deploy_configuration
    install_system
    cleanup_and_finish
}

# Handle script interruption and errors
trap cleanup_on_error ERR
trap 'log "ERROR" "Installation interrupted"; cleanup_on_error; exit 1' INT TERM

main "$@"
