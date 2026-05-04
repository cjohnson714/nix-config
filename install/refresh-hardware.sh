#!/usr/bin/env bash
# Regenerate hardware-configuration.nix from the *running* machine and rebuild.
# Use when disks/NVMe IDs changed and you do not want to hand-edit hardware modules.
#
#   sudo ./install/refresh-hardware.sh athena
#
set -euo pipefail

[[ "${EUID:-0}" -eq 0 ]] || {
  echo "run as root: sudo $0 $*"
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOST="${1:?usage: $0 <flake-hostname>}"

[[ -f "$REPO_ROOT/flake.nix" ]] || {
  echo "flake.nix not found under $REPO_ROOT"
  exit 1
}

[[ -d "$REPO_ROOT/hosts/$HOST" ]] || {
  echo "no hosts/$HOST — pick a host name from hosts/registry.nix"
  exit 1
}

TMP="$(mktemp -d)"
nixos-generate-config --dir "$TMP" --root /
cp "$TMP/hardware-configuration.nix" "$REPO_ROOT/hosts/$HOST/hardware-configuration.nix"
chmod 0644 "$REPO_ROOT/hosts/$HOST/hardware-configuration.nix"
rm -rf "$TMP"

echo "Wrote hosts/$HOST/hardware-configuration.nix — rebuilding…"
nixos-rebuild switch --flake "$REPO_ROOT#$HOST"
echo "Done."
