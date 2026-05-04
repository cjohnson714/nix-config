#!/usr/bin/env bash
#
# One-shot entry for the NixOS live ISO: clone this flake and run the installer.
#
#   curl -fsSL 'https://raw.githubusercontent.com/OWNER/REPO/BRANCH/install/curl-installer.sh' | sudo bash
#
# Environment (all optional):
#   NIX_CONFIG_REPO_URL   Git URL (default below)
#   NIX_CONFIG_BRANCH     Branch or tag (default: main)
#   NIX_CONFIG_CLONE_DIR  Clone destination (default: /tmp/nix-config-install)
#
set -euo pipefail

: "${NIX_CONFIG_REPO_URL:=https://github.com/cjohnson714/nix-config.git}"
: "${NIX_CONFIG_BRANCH:=main}"
: "${NIX_CONFIG_CLONE_DIR:=/tmp/nix-config-install}"

die() {
  echo "error: $*" >&2
  exit 1
}

[[ "${EUID:-0}" -eq 0 ]] || die "run with: curl ... | sudo bash"

command -v git &>/dev/null || die "git not found — on the ISO run: nix-shell -p git --run 'curl ... | sudo bash'"

rm -rf "$NIX_CONFIG_CLONE_DIR"
git clone --depth 1 --branch "$NIX_CONFIG_BRANCH" "$NIX_CONFIG_REPO_URL" "$NIX_CONFIG_CLONE_DIR"

export REPO_ROOT="$NIX_CONFIG_CLONE_DIR"
cd "$NIX_CONFIG_CLONE_DIR" || die "cd failed"

exec bash ./install/bootstrap.sh "$@"
