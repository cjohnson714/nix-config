#!/usr/bin/env bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ensure the script is run from within the nix-config directory (check for flake.nix file)
if [[ ! -f "flake.nix" ]]; then
   echo "Error: This script must be run from within the nix-config directory."
   exit 1
fi

# Accept an optional argument for the system name, default to "nixos-vm" if not provided
SYSTEM_NAME="${1:-nixos-vm}"

echo "Generating NixOS configuration..."
nixos-generate-config

echo "Copying hardware configuration..."
rm hosts/${SYSTEM_NAME}/hardware-configuration.nix
cp /etc/nixos/hardware-configuration.nix hosts/${SYSTEM_NAME}/

# Adjust the ownership to the current user after copying
echo "Changing ownership of hardware-configuration.nix to the current user..."
chown $(whoami):$(whoami) hosts/${SYSTEM_NAME}/hardware-configuration.nix

echo "Rebuilding NixOS system..."
nixos-rebuild switch \
  --flake .#${SYSTEM_NAME} \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters "https://chaotic-nyx.cachix.org https://catppuccin.cachix.org" \
  --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8= catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="

echo "Installation and configuration complete!"
