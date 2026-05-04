#!/usr/bin/env bash
# Runtime hardware heuristics for the installer. Nix evaluation cannot see /proc or PCI,
# so these tags feed `hosts/registry.nix` (platform / gpu) which map to `nixos/profiles/*`.

detect_virt() {
  if command -v systemd-detect-virt &>/dev/null; then
    systemd-detect-virt 2>/dev/null || true
  else
    echo "none"
  fi
}

detect_is_raspberry() {
  if [[ -f /proc/device-tree/model ]]; then
    tr -d '\0' </proc/device-tree/model | grep -qi raspberry && return 0
  fi
  return 1
}

detect_is_laptop() {
  if [[ -d /sys/class/power_supply ]]; then
    for s in /sys/class/power_supply/*; do
      [[ -f "$s/type" ]] || continue
      if grep -qix Battery "$s/type" 2>/dev/null; then
        return 0
      fi
    done
  fi
  return 1
}

detect_platform_tag() {
  local virt
  virt="$(detect_virt)"
  if [[ "$virt" != "none" ]]; then
    echo "vm"
    return
  fi
  if detect_is_raspberry; then
    echo "raspberry"
    return
  fi
  if detect_is_laptop; then
    echo "laptop"
    return
  fi
  echo "desktop"
}

detect_gpu_tag() {
  local virt
  virt="$(detect_virt)"
  if [[ "$virt" != "none" ]]; then
    echo "qemu"
    return
  fi
  if ! command -v lspci &>/dev/null; then
    echo "none"
    return
  fi
  if lspci -nn 2>/dev/null | grep -qi 'nvidia'; then
    echo "nvidia"
    return
  fi
  if lspci -nn 2>/dev/null | grep -qiE 'vga.*amd|amdgpu|radeon'; then
    echo "amdgpu"
    return
  fi
  if lspci -nn 2>/dev/null | grep -qiE 'vga.*intel|iris|uhd graphics'; then
    echo "intel"
    return
  fi
  echo "none"
}
