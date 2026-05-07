# NixOS configuration

Personal [NixOS](https://nixos.org/) configuration using **flakes**, **[Home Manager](https://github.com/nix-community/home-manager)**, and **[Snowfall Lib](https://snowfall.org/)** for consistent flake outputs and layout.

---

## Overview


| Piece            | Role                                                                                                  |
| ---------------- | ----------------------------------------------------------------------------------------------------- |
| **Flakes**       | Pins inputs in `flake.lock`; single entry point                                                       |
| **Snowfall Lib** | `mkFlake` for `nixosConfigurations`, `homeConfigurations`, `systems/`, `homes/`                       |
| **Home Manager** | Composable modules under `modules/home/<topic>/` (see below); entry in `homes/x86_64-linux/hana/` |
| **Systems**      | Each machine is `systems/<arch>/<hostname>/` (config + hardware)                                      |


### Hosts


| Hostname   | Role            |
| ---------- | --------------- |
| `sakura`   | Primary desktop |
| `nixos-vm` | QEMU / VM       |


Primary user: **hana**. One target-wide Home Manager home applies to all `x86_64-linux` systems: `homes/x86_64-linux/hana/`.

---

## Layout

```
.
├── flake.nix
├── flake.lock
├── nix/
│   └── shared-system-modules.nix
├── systems/x86_64-linux/
│   ├── sakura/
│   └── nixos-vm/
├── homes/x86_64-linux/
│   └── hana/
│       └── default.nix          # imports modules/home (full HM profile)
├── modules/
│   ├── home/                    # Home Manager: postmodern-style topics
│   │   ├── default.nix          # aggregator
│   │   ├── core/ shell/ terminal/ nix/ cli/ theming/ files/
│   │   ├── browser/ editors/ git/ gaming/ media/ messaging/ lftp/ gpu/
│   │   └── wayland/             # Niri
│   ├── users/
│   └── system/
├── overlays/
├── pkgs/
├── config/                      # Static dotfiles referenced from modules/home
└── install.sh
```

Home Manager topics follow the **postmodern-linux-stack** convention: one folder per concern (e.g. `browser/`, `wayland/`, `terminal/`, `shell/`, `nix/`, `editors/`), each with a `default.nix`. NixOS-only bits stay under `modules/system/`, not here.

---

## Prerequisites

- Flakes + `nix-command` (enabled in `modules/system/` after a successful rebuild; the installer may still need `--extra-experimental-features "nix-command flakes"`).
- Git for remote flake inputs.

---

## Quick start

```bash
git clone https://github.com/cjohnson714/nix-config.git
cd nix-config

nix flake show
nix flake check
```

Apply configuration:

```bash
sudo nixos-rebuild switch --flake .#sakura
# or
sudo nixos-rebuild switch --flake .#nixos-vm
```

---

## Hardware configuration

On the machine:

```bash
sudo nixos-generate-config --show-hardware-config > /tmp/hw.nix
cp /tmp/hw.nix systems/x86_64-linux/<hostname>/hardware-configuration.nix
git add systems/x86_64-linux/<hostname>/hardware-configuration.nix
```

Or run `./install.sh` from the repo (as root, from repo root); it writes to `systems/x86_64-linux/<name>/hardware-configuration.nix` and runs `nixos-rebuild switch`.

---

## Adding a host

1. Copy `systems/x86_64-linux/nixos-vm/` (or `sakura/`) to `systems/x86_64-linux/<hostname>/` and edit `default.nix` + hardware.
2. If you add another Unix user with their own Snowfall home, add `modules/users/<name>.nix` and extend `username` / `shared-system-modules` logic in `flake.nix` as needed.
3. Register the host in `flake.nix`:

```nix
systems.hosts.<hostname> = {
  inherit specialArgs;
  modules = sharedSystemModules;
};
```

1. Run `nix flake check` and `sudo nixos-rebuild switch --flake .#<hostname>`.

---

## Home Manager and Snowfall

- Entry point: `homes/x86_64-linux/hana/default.nix` imports `modules/home` (the full topic tree).
- Shared HM inputs (Catppuccin, Zen browser) are set in `flake.nix` via `homes.modules`.
- `nix flake check` may warn about extra outputs (`snowfall`, `pkgs`); that is normal for Snowfall flakes.

---

## Credits

Inspired by [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## License

MIT — see [LICENSE](LICENSE).