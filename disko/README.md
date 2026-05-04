# Disk layouts (disko)

Schemes are NixOS modules under `schemes/`; they set `disko.devices` and use **`lib.mkDefault`** on things I expect to override (disk path, LUKS `passwordFile`, `allowDiscards`).

Flake: `flake.diskoConfigurations.<name>` in `parts/disko.nix`.

| Scheme | |
|--------|---|
| `btrfs-efi-simple` | ESP + btrfs `/` |
| `ext4-efi-simple` | ESP + ext4 `/` |
| `btrfs-luks-efi-simple` | ESP + LUKS + btrfs (see scheme file) |

The ISO installer writes **`hosts/<name>/disko-scheme.nix`** and imports **`inputs.disko.nixosModules.disko`** — read `install/README.md` for the flow.
