# NixOS flake configuration

Declarative NixOS and Home Manager setup built with **flake-parts**, a **registry-driven host model**, and optional **disko** layouts for unattended installs from the live ISO.

---

## Table of contents

1. [Features](#features)
2. [Repository layout](#repository-layout)
3. [Install from the live ISO (curl)](#install-from-the-live-iso-curl)
4. [Install with an existing clone](#install-with-an-existing-clone)
5. [Day-two: rebuild on an installed system](#day-two-rebuild-on-an-installed-system)
6. [Adding or changing hosts](#adding-or-changing-hosts)
7. [Custom host templates](#custom-host-templates)
8. [Security baseline](#security-baseline)
9. [Disk layouts, LUKS, and `disko-scheme.nix`](#disk-layouts-luks-and-disko-schemenix)
10. [`mkDefault`, `mkForce`, and `mkMerge`](#mkdefault-mkforce-and-mkmerge)
11. [Nix style: `mkIf` and when to split more](#nix-style-mkif-and-when-to-split-more)
12. [License](#license)

---

## Features

- **flake-parts** for `perSystem` formatters/apps and flake-level `nixosConfigurations` / `diskoConfigurations`.
- **One host registry** (`hosts/registry.nix`) plus optional **`hosts/registry.local.nix`** (gitignored) for machines created by the installer or local overrides.
- **Composable profiles**: `platform` (`desktop` / `laptop` / `vm` / `raspberry`) and `gpu` (`none` / `nvidia` / `amdgpu` / `intel` / `qemu`) under `nixos/profiles/`.
- **Locked disko** via the flake app **`#disko`** (no `nix run …/latest` drift).
- **Installer scripts** under `install/` with hardware **detection in shell** (Nix cannot read PCI/DMI at eval time).

---

## Repository layout

| Path | Purpose |
|------|---------|
| `flake.nix` | Inputs, `nixConfig` substituters, `flake-parts.lib.mkFlake` entry. |
| `parts/` | flake-parts modules (`nixos`, `formatter`, `apps`, `disko`). |
| `hosts/registry.nix` | Single source of truth for `nixosConfigurations` keys and metadata. |
| `hosts/<name>/` | Bootloader, LUKS, `hardware-configuration.nix`, machine-only tweaks. |
| `nixos/modules/` | Shared NixOS modules (`system/`, `bspwm.nix`, `niri.nix`, …). |
| `nixos/modules/security/baseline.nix` | Cross-cutting hardening (see below). |
| `nixos/profiles/` | `platform/*` and `gpu/*` selectors from the registry. |
| `nix/overlays/` | `nixpkgs` overlays (custom packages). |
| `packages/` | Overlay package definitions (`callPackage`). |
| `home/` | Home Manager modules and dotfile wiring. |
| `users/<name>/` | `home.nix` / `nixos.nix` for that primary user. |
| `config/` | Static config files referenced from Home Manager. |
| `disko/schemes/` | Disk layouts (`flake.diskoConfigurations.*`); see `disko/README.md`. |
| `hosts/_templates/` | Reference snippets (e.g. installer `default.nix` with disko). |
| `install/` | `bootstrap.sh`, `curl-installer.sh`, `lib/` helpers. |

---

## Install from the live ISO (curl)

On the official NixOS live image (enable flakes / use a recent ISO):

1. Install Git if needed: `nix-shell -p git`.
2. Run (replace owner, repo, and branch):

```bash
curl -fsSL 'https://raw.githubusercontent.com/OWNER/REPO/BRANCH/install/curl-installer.sh' | sudo bash
```

Environment variables for `curl-installer.sh`:

| Variable | Default | Meaning |
|----------|---------|---------|
| `NIX_CONFIG_REPO_URL` | `https://github.com/cjohnson714/nix-config.git` | Repository to clone. |
| `NIX_CONFIG_BRANCH` | `main` | Branch or tag. |
| `NIX_CONFIG_CLONE_DIR` | `/tmp/nix-config-install` | Clone directory (removed before clone). |

The clone runs **`install/bootstrap.sh`**, which:

- Detects **platform** and **GPU tags** (VM, laptop, Raspberry Pi heuristics; `lspci` when available).
- Prompts for **flake output name** (directory under `hosts/`), **username**, **disko scheme**, **disk device**, and optional **HOST_MODULE** (see [Custom host templates](#custom-host-templates)).
- Writes **`hosts/<name>/disko-scheme.nix`** (rendered scheme with your disk path) and a **`default.nix`** that imports **`inputs.disko.nixosModules.disko`** so future **`nixos-rebuild`** stays consistent with the layout (stacked installs; see [Disk layouts](#disk-layouts-luks-and-disko-schemenix)).
- For **LUKS** schemes (`DISKO_SCHEME` name contains `luks`), prompts for a passphrase (or **`LUKS_PASSWORD`** when fully non-interactive — avoid on shared machines) written to `/tmp/disko-luks-password` for disko only, then removed.
- Writes **`hosts/registry.local.nix`**, runs **disko**, generates **`hardware-configuration.nix`**, then **`nixos-install --flake .#<name>`**.

You must confirm disk destruction unless you set:

```bash
export INSTALL_I_UNDERSTAND_THIS_ERASES_THE_DISK=1
```

Fully non-interactive example:

```bash
export INSTALL_NON_INTERACTIVE=1
export INSTALL_I_UNDERSTAND_THIS_ERASES_THE_DISK=1
export PRESET=personal
export FLAKE_HOST=mybox
export DISK=/dev/disk/by-id/nvme-eui.XXXXXXXX
export DISKO_SCHEME=btrfs-luks-efi-simple
export LUKS_PASSWORD='use-only-on-trusted-isos'
export NEW_USERNAME=you
curl -fsSL 'https://raw.githubusercontent.com/OWNER/REPO/BRANCH/install/curl-installer.sh' | sudo bash
```

After install: set passwords (`passwd`), reboot, then adjust `hosts/<name>/` and drop `registry.local.nix` or merge entries into `hosts/registry.nix` when you are happy with them.

---

## Install with an existing clone

```bash
cd /path/to/nix-config
sudo ./install/bootstrap.sh
```

Optional environment (same semantics as above): `PRESET`, `FLAKE_HOST`, `DISK`, `DISKO_SCHEME`, `NEW_USERNAME`, `HOST_MODULE`, `LUKS_PASSWORD` (LUKS + non-interactive only), `INSTALL_*`.

Use the flake’s pinned CLI (from repo root):

```bash
nix run .#disko -- --help
```

---

## Day-two: rebuild on an installed system

```bash
cd /path/to/nix-config
sudo nixos-rebuild switch --flake .#<hostname>
```

Helper script in repo root (`install.sh`) can refresh `hardware-configuration.nix` for a given host name; prefer `nixos-generate-config --show-hardware-config` when you change disks or firmware.

---

## Adding or changing hosts

1. Add a directory under `hosts/<name>/` with `default.nix` and usually `hardware-configuration.nix`.
2. Register it in **`hosts/registry.nix`**:

```nix
my-laptop = {
  system = "x86_64-linux";
  username = "you";
  platform = "laptop";
  gpu = "intel";
  host = ./my-laptop;
  # Optional:
  # hostname = "my-laptop";          # defaults to attr name
  # extraModules = [ ./extras.nix ];
  # homeImports = [ ./home-extra.nix ];
};
```

3. Ensure `users/<username>/` exists (Home Manager and user fragment today assume that layout).

For installer-generated machines, use **`hosts/registry.local.nix`** (see `hosts/registry.local.nix.example`) so generated entries stay out of git until you promote them.

---

## Custom host templates

**Single fragment (`.nix` file)** — merged on top of the default stack (system + niri + hardware):

```bash
export HOST_MODULE=hosts/templates/fragment.nix
sudo ./install/bootstrap.sh
```

Paths are relative to the repo root unless they start with `/`.

**Full host directory** — must contain its own `default.nix` (and anything else you need). The installer copies the tree into `hosts/<flake-host>/`, writes **`disko-scheme.nix`** next to it, and overwrites **`hardware-configuration.nix`**. If your template does not import **`inputs.disko.nixosModules.disko`** and **`./disko-scheme.nix`**, the script prints a warning; use **`hosts/_templates/installer-default.nix`** as a reference.

---

## Disk layouts, LUKS, and `disko-scheme.nix`

Schemes live under **`disko/schemes/`** and are re-exported as **`flake.diskoConfigurations.<name>`** (`parts/disko.nix`).

| Name | Purpose |
|------|---------|
| `btrfs-efi-simple` | Unencrypted btrfs root + ESP. |
| `ext4-efi-simple` | Unencrypted ext4 root + ESP. |
| `btrfs-luks-efi-simple` | LUKS container with btrfs (`cryptroot`), ESP on cleartext `/boot`. |

Placeholders such as **`lib.mkDefault "/dev/disk/by-id/CHANGE_ME"`** exist so **`install/lib/render_disko.py`** can substitute the target device without `mkForce`. LUKS **`passwordFile`** defaults to **`/tmp/disko-luks-password`** during the install run only.

---

## `mkDefault`, `mkForce`, and `mkMerge`

- **`lib.mkDefault value`** — sets a *default priority* merge: other modules can override with a plain value, and you can still win with `mkForce`. Use for “sensible defaults” in shared modules and disko templates (device path, `allowDiscards`, optional `passwordFile` path).
- **`lib.mkForce value`** — highest priority; use sparingly for policy that must not be overridden by accident.
- **`lib.mkMerge [ { ... } { ... } ]`** — combine attrsets inside one module when building config programmatically. You do **not** need `mkMerge` “everywhere”; most configs read clearer as multiple `imports` or small attr sets.

---

## Security baseline

`nixos/modules/security/baseline.nix` is imported from the shared system stack and sets conservative defaults:

- `security.pam.services.su.requireWheel`
- SSH: lower `MaxAuthTries`, `LoginGraceTime`, disable keyboard-interactive
- `kernel.yama.ptrace_scope` tightened

It uses **`lib.mkDefault`** so host-specific or profile modules can override without `mkForce` fights. For stricter knobs (fail2ban, kernel lockdown, automatic updates), add focused modules under `nixos/modules/security/` or per-host `extraModules` rather than growing one mega-file.

---

## Nix style: `mkIf` and when to split more

- **`mkIf`** is for *conditional fragments inside one module* when the condition is cheap and local (`cfg.services.foo.enable`). It is not a goal to wrap “everything” in `mkIf`; that hurts readability.
- Prefer **`imports = lib.optionals cond [ ./b.nix ]`**, or **separate `.nix` files** merged with `imports`, over giant `mkIf` blocks.
- **`mkDefault` / `mkForce` / `mkMerge`** — see the section above; they solve *merge priority* and *attrset assembly*, not the same problem as `mkIf`.
- **Runtime facts** (disk layout, PCI IDs, “is this a VM?”) belong in **install scripts** or `hardware-configuration.nix`, not in pure flake eval, unless you import generated snippets.

This repo is already split at sensible boundaries (flake-parts parts, system slices, profiles, hosts). Further splits should follow *new concerns* (e.g. a dedicated `security/` tree, or a `suites/` concept), not churn for its own sake.

---

## License

See [LICENSE](LICENSE). Portions were inspired by other MIT-licensed NixOS configs referenced in earlier revisions of this README.
