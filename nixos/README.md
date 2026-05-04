# NixOS side

- **`modules/`** — shared system modules (`system/` is the big slice, plus `bspwm.nix`, `niri.nix`, `security/baseline.nix`, …).
- **`profiles/platform|gpu/`** — small toggles chosen from `hosts/registry.nix` (`platform`, `gpu`).

Hosts pull these together; I keep machine-specific boot and disks under **`hosts/<name>/`**.
