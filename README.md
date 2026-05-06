# NixOS configuration

Personal [NixOS](https://nixos.org/) system config using **flakes**, [**Home Manager**](https://github.com/nix-community/home-manager), and [**Snowfall Lib**](https://snowfall.org/) to keep outputs and directory layout consistent.

---

## Overview

| Piece | Role |
|--------|------|
| **Flakes** | Pins inputs in `flake.lock`; `nix develop` / `nix build` entry point |
| **Snowfall Lib** | `mkFlake` wiring for `nixosConfigurations`, `homeConfigurations`, and the `systems/` + `homes/` layouts |
| **Home Manager** | User environment under `home/`; integrated via Snowfall (see `homes/`) |
| **Hosts** | Machine-specific NixOS modules live under `systems/<arch>/<hostname>/`; thin wrappers in `hosts/` re-export them for familiar paths |

### Defined hosts

| Hostname | Role |
|----------|------|
| `athena` | Primary desktop (bare metal) |
| `nixos-vm` | QEMU / VM profile |

Common user: **integrus**. Home Manager is declared in Snowfall as a target-wide home for `x86_64-linux` (`homes/x86_64-linux/integrus/`).

---

## Repository layout

```
.
├── flake.nix                 # Snowfall mkFlake outputs and shared modules
├── flake.lock
├── systems/x86_64-linux/     # Canonical Snowfall system definitions
│   ├── athena/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── nixos-vm/
│       ├── default.nix
│       └── hardware-configuration.nix
├── homes/x86_64-linux/
│   └── integrus/
│       └── default.nix       # Home Manager entry (imports home/*)
├── hosts/                    # Compatibility shims → systems/…
├── home/                     # Home Manager modules (programs, shell, desktop, …)
├── modules/                  # Shared NixOS modules
├── users/integrus/
│   ├── home.nix              # Shim → homes/…/integrus
│   └── nixos.nix             # Per-user NixOS snippets + Snowfall user options
├── overlays/
├── pkgs/
└── config/                   # Dotfiles and static config tracked into HM
```

---

## Prerequisites

- Nix with **flakes** and **`nix-command`** (see `experimental-features` in `modules/system.nix` once the system is built; the installer may still need `--extra-experimental-features "nix-command flakes"`).
- Git, if you use flake inputs that fetch from GitHub.

---

## Quick start

Clone and inspect the flake:

```bash
git clone https://github.com/cjohnson714/nix-config.git
cd nix-config

nix flake show    # add --extra-experimental-features "nix-command flakes" if needed
nix flake check
```

Switch system configuration (pick your host):

```bash
sudo nixos-rebuild switch --flake .#athena
# or
sudo nixos-rebuild switch --flake .#nixos-vm
```

If your shell does not yet enable flakes by default, prefix commands with:

```bash
nix --extra-experimental-features "nix-command flakes" flake check
```

---

## Hardware configuration

After installation, generate hardware config on the target machine:

```bash
sudo nixos-generate-config --show-hardware-config > /tmp/hw.nix
```

Install the file into this repo for your host, for example:

```bash
cp /tmp/hw.nix systems/x86_64-linux/<hostname>/hardware-configuration.nix
```

The matching `hosts/<hostname>/hardware-configuration.nix` re-exports that file; keep both in sync or edit only the `systems/` copy and let the shim import it.

Commit the result so the flake source includes your disks and kernels:

```bash
git add systems/x86_64-linux/<hostname>/hardware-configuration.nix
```

---

## Adding a new host

1. Copy an existing tree under `systems/x86_64-linux/` and rename it to your hostname.
2. Adjust `systems/x86_64-linux/<hostname>/default.nix` (hostname, disks, drivers, etc.) and install a `hardware-configuration.nix` for that machine.
3. Register the host in `flake.nix` inside `inputs.snowfall-lib.mkFlake { ... }`:

```nix
systems.hosts.<hostname> = {
  specialArgs = specialArgs;   # same pattern as athena / nixos-vm
  modules = sharedSystemModules;
};
```

4. Optionally add `hosts/<hostname>/` shims that import `../../systems/x86_64-linux/<hostname>` if you want to keep the old layout for scripts or muscle memory.

5. Run `nix flake check` and `sudo nixos-rebuild switch --flake .#<hostname>`.

---

## Home Manager and Snowfall

- Canonical home entry: **`homes/x86_64-linux/integrus/default.nix`** (imports pieces under `home/`).
- **`users/integrus/home.nix`** re-exports that tree for compatibility.
- Snowfall may expose extra flake outputs (for example `snowfall`, `pkgs`); `nix flake check` may warn that some outputs are unknown to older Nix versions. That is expected and safe to ignore unless you rely on those outputs explicitly.

---

## Credits

Inspired by [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## License

MIT — see [LICENSE](LICENSE).
