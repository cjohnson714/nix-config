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

# Create a temporary directory
TMP_DIR=$(mktemp -d)

# Generate the config into the temporary directory
nixos-generate-config --dir "$TMP_DIR"

# Copy ONLY the hardware-configuration.nix file
cp "$TMP_DIR/hardware-configuration.nix" hosts/${SYSTEM_NAME}/

# Adjust the ownership to the original user after copying
echo "Changing ownership of hardware-configuration.nix to the original user..."

# Get the original user's username using logname
ORIGINAL_USER=$(logname)

# Get the UID and GID of the original user
ORIGINAL_UID=$(id -u "$ORIGINAL_USER")
ORIGINAL_GID=$(id -g "$ORIGINAL_USER")

# Check if the IDs are valid
if [[ -n "$ORIGINAL_UID" && "$ORIGINAL_UID" != ":" && -n "$ORIGINAL_GID" && "$ORIGINAL_GID" != ":" ]]; then
  chown "$ORIGINAL_UID:$ORIGINAL_GID" hosts/${SYSTEM_NAME}/hardware-configuration.nix
else
  echo "Warning: Could not determine original user/group IDs. Skipping ownership change."
fi

# Remove the temporary directory and its contents
rm -rf "$TMP_DIR"

echo "Rebuilding NixOS system..."

nixos-rebuild switch \
  --flake .#${SYSTEM_NAME} \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters "https://chaotic-nyx.cachix.org https://catppuccin.cachix.org" \
  --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8= catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="

echo "Installation and configuration complete!"