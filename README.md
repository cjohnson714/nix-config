# My NixOS flake

> **What this is:** my whole desktop stack (NixOS + Home Manager) in one repo. I want to **curl a script on the live ISO**, answer a short prompt or two, and land in a working system **without hand-copying `hardware-configuration.nix`** or shuffling files between disks. If you are reading this as someone else: fork it, rip out what you do not want, point `hosts/registry.nix` at your user — same bones, your choices.

---

### The path I actually use

1. Boot the **NixOS live image** (flakes on, network up).
2. `nix-shell -p git` if `git` is missing.
3. Run (swap branch / URL if you are not tracking `main`):

```bash
curl -fsSL 'https://raw.githubusercontent.com/cjohnson714/nix-config/main/install/curl-installer.sh' | sudo bash
```

That clones this repo and runs **`install/bootstrap.sh`**. Because the default clone URL is mine, you get a **single summary screen**: what I detected for platform/GPU, the disk I guessed, LUKS vs not, flake hostname, user. If it looks right, hit **Enter** and then confirm the wipe + LUKS passphrase when asked.

**I do not want the hand-holding:** `OWNER_QUICKSTART=0` before running, or clone any other URL so `NIX_CONFIG_UPSTREAM_DEFAULT` is not set.

**Tweaks without editing Nix first:** `OWNER_DEFAULT_USERNAME`, `OWNER_DEFAULT_SCHEME`, `DISK`, `DISKO_SCHEME`, `FLAKE_HOST`, `HOST_MODULE=…` — all documented in the header of `install/bootstrap.sh`.

---

### If you are not me

- Change **`hosts/registry.nix`** and add **`users/<you>/`** (or repoint `username` + imports in `lib/mk-nixos.nix` if you go harder than the registry).
- **`home/programs/default.nix`** pulls in **groups** under `home/programs/groups/` (`core`, `development`, `leisure`, `network`, `hardware`). Comment out a group to drop a whole category.
- **`nixos/profiles/`** maps `platform` + `gpu` tags from the registry — add a file there if you need a new tag.

---

### Repo map (where stuff lives)

| Path | |
|------|---|
| `flake.nix` | Inputs + `flake-parts` entry. |
| `parts/` | Formatter, `nixosConfigurations`, disko apps, etc. |
| `hosts/` | One dir per machine + **`registry.nix`**. See `hosts/README.md`. |
| `nixos/` | System modules + `profiles/`. See `nixos/README.md`. |
| `home/` | Home Manager. See `home/README.md`. |
| `install/` | ISO install + **`refresh-hardware.sh`**. See `install/README.md`. |
| `disko/schemes/` | Partition layouts. See `disko/README.md`. |
| `config/` | Dotfiles / static configs referenced from Home Manager. |

---

### After install (day two)

```bash
cd /path/to/this/repo
sudo nixos-rebuild switch --flake .#<hostname>
```

`<hostname>` is the flake output key — same as the folder name under `hosts/` unless you overrode `hostname` in the registry.

---

### When the machine moves or the disk ID changes

I do **not** want to merge `hardware-configuration.nix` by hand. On the installed system, from a clone of this repo:

```bash
sudo ./install/refresh-hardware.sh athena
```

That regenerates from `/` and rebuilds. (`./install.sh` at repo root still works too — same idea.)

---

### Disk layouts & LUKS

Schemes live in **`disko/schemes/`** and are wired as **`flake.diskoConfigurations.*`**. The installer renders **`hosts/<name>/disko-scheme.nix`** and imports **`inputs.disko.nixosModules.disko`** in that host’s `default.nix` so `nixos-rebuild` stays honest.

- **`btrfs-efi-simple`** — fast, no LUKS (I default to this on **VM** quick path).
- **`btrfs-luks-efi-simple`** — what I default to on **real metal** quick path.
- **`ext4-efi-simple`** — boring ext4.

`lib.mkDefault` in those files is on purpose: lower merge priority so overrides stay easy. **`mkForce`** is for when I really mean “nothing gets to change this.” **`mkMerge`** only when I am building attrsets from a list — I do not sprinkle it everywhere; separate modules read better.

---

### `mkIf` (when I bother)

I use **`mkIf`** when something is genuinely conditional inside one module. For whole features I prefer **`imports = lib.optionals cond [ ./foo.nix ]`** or another file. I am not trying to win “most `mkIf` per line.”

---

### License

MIT — see `LICENSE`.
