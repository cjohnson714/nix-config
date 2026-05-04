#!/usr/bin/env bash
# Refresh hardware-configuration.nix for a host registered in hosts/registry.nix, then rebuild.
# Usage (from repo root, as root): ./install.sh [hostname]
# Fresh ISO install: see README.md and install/bootstrap.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

if [[ ! -f flake.nix ]]; then
  echo "Error: run from the repository root (flake.nix missing)."
  exit 1
fi

SYSTEM_NAME="${1:-nixos-vm}"

echo "Generating hardware-configuration.nix for hosts/${SYSTEM_NAME}/ ..."

TMP_DIR="$(mktemp -d)"
nixos-generate-config --dir "$TMP_DIR"
cp "$TMP_DIR/hardware-configuration.nix" "hosts/${SYSTEM_NAME}/"
rm -rf "$TMP_DIR"

ORIGINAL_USER="$(logname 2>/dev/null || true)"
if [[ -n "$ORIGINAL_USER" ]]; then
  ORIGINAL_UID="$(id -u "$ORIGINAL_USER")"
  ORIGINAL_GID="$(id -g "$ORIGINAL_USER")"
  chown "${ORIGINAL_UID}:${ORIGINAL_GID}" "hosts/${SYSTEM_NAME}/hardware-configuration.nix" 2>/dev/null || true
fi

echo "Rebuilding NixOS system..."
nixos-rebuild switch --flake ".#${SYSTEM_NAME}"

echo "Done."
