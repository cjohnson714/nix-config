#!/usr/bin/env bash
# "Just say yes" flow for my usual clone + defaults. Anyone else: set OWNER_QUICKSTART=0 or use another repo URL.

owner_quickstart_wanted() {
  [[ "${INSTALL_NON_INTERACTIVE:-}" == "1" ]] && return 1
  [[ "${OWNER_QUICKSTART:-}" == "1" ]] && return 0
  [[ "${NIX_CONFIG_UPSTREAM_DEFAULT:-}" == "1" ]] && return 0
  return 1
}

owner_default_scheme_for_platform() {
  [[ -n "${OWNER_DEFAULT_SCHEME:-}" ]] && {
    echo "$OWNER_DEFAULT_SCHEME"
    return
  }
  case "$1" in
    vm) echo "btrfs-efi-simple" ;;
    *) echo "btrfs-luks-efi-simple" ;;
  esac
}

owner_default_username() {
  echo "${OWNER_DEFAULT_USERNAME:-integrus}"
}

owner_suggest_flake_host() {
  local h
  h="$(hostname 2>/dev/null || echo nixos)"
  h="${h//[^a-zA-Z0-9-]/-}"
  h="${h,,}"
  [[ -z "$h" || "$h" == "nixos" ]] && h="nixos-install"
  echo "$h"
}

print_install_summary() {
  local mach="$1" plat="$2" gpu="$3" sys="$4" disk="$5" scheme="$6" host="$7" user="$8"
  echo ""
  echo "  ╭── Quick install (detected) ─────────────────────────────────"
  echo "  │ Machine : $mach"
  echo "  │ Platform: $plat   GPU profile: $gpu   System: $sys"
  echo "  │ Disk    : ${disk:-<not set — you must pick one>}"
  echo "  │ Layout  : $scheme"
  echo "  │ Flake # : $host   User: $user"
  echo "  ╰──────────────────────────────────────────────────────────────"
  echo ""
}

prompt_quick_correct() {
  local ans
  read -r -p "  Does that all look right? [Y/n/edit] " ans || true
  ans="${ans:-Y}"
  case "${ans,,}" in
    "" | y | yes) return 0 ;;
    n | no) return 1 ;;
    e | edit) return 2 ;;
    *) return 1 ;;
  esac
}
