#!/usr/bin/env bash
# Shared helpers for install/*.sh — source after setting REPO_ROOT (repo root containing flake.nix).

die() {
  echo "error: $*" >&2
  exit 1
}

require_root() {
  [[ "${EUID:-0}" -eq 0 ]] || die "run as root (NixOS live ISO: sudo -i)"
}

require_repo() {
  [[ -n "${REPO_ROOT:-}" ]] || die "REPO_ROOT is not set"
  [[ -f "$REPO_ROOT/flake.nix" ]] || die "flake.nix not found under REPO_ROOT=$REPO_ROOT"
}

confirm_wipe() {
  local disk="$1"
  [[ "${INSTALL_I_UNDERSTAND_THIS_ERASES_THE_DISK:-}" == "1" ]] && return 0
  echo "The next step will partition and ERASE: $disk"
  read -r -p "Type YES to continue: " ans
  [[ "$ans" == "YES" ]] || die "aborted"
}
