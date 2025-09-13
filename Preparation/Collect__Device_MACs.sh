#!/usr/bin/env bash
# generate a list of MACs for this device for Nix configuration to utilise
echo "{ systemMacs = [" > /etc/nixos/device-macs.nix
cat /sys/class/net/*/address | grep -v "00:00:00:00:00:00" | sed 's/.*/    "&"/' >> /etc/nixos/device-macs.nix
echo "]; }" >> /etc/nixos/device-macs.nix
