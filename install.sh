#!/usr/bin/env bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ensure the script is run from within the nix-config directory (check for flake.nix file)
if [[ ! -f "flake.nix" ]]; then
   echo "Error: This script must be run from within the nix-config directory."
   exit 1
fi

# Generate the NixOS configuration files
echo "Generating NixOS configuration..."
nixos-generate-config

# Replace the hardware-configuration.nix file
echo "Copying hardware configuration..."
rm hosts/nixos-vm/hardware-configuration.nix
cp /etc/nixos/hardware-configuration.nix hosts/nixos-vm/

# Run the nixos-rebuild with flakes, custom substitutor, and experimental features enabled
echo "Rebuilding NixOS system..."
nixos-rebuild switch \
  --flake .#nixos-vm \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters "https://chaotic-nyx.cachix.org" \
  --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="

echo "Installation and configuration complete!"
