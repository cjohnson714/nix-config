# Disk layouts (disko)

Schemes in `schemes/` are **NixOS modules** that set `disko.devices`. They use:

- `lib.mkDefault "…"` for values installers or hosts should override easily (disk path, optional LUKS `passwordFile`, `allowDiscards`).

Flake outputs: `flake.diskoConfigurations.<name>` (see `parts/disko.nix`).

| Scheme | Layout |
|--------|--------|
| `btrfs-efi-simple` | GPT: ESP + btrfs `/` |
| `ext4-efi-simple` | GPT: ESP + ext4 `/` |
| `btrfs-luks-efi-simple` | GPT: ESP + LUKS + btrfs `@root` → `/` |

Installer: `install/bootstrap.sh` renders the device placeholder and copies the result to `hosts/<hostname>/disko-scheme.nix`, then imports `inputs.disko.nixosModules.disko` in that host’s `default.nix` so `nixos-rebuild` stays aligned with the layout.
