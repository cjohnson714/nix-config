# Hosts

Each subdirectory is one **flake output** (`nixosConfigurations.<name>`), registered in **`registry.nix`** (or **`registry.local.nix`** for machines the installer created).

- **`default.nix`** — boot, LUKS, imports, anything that is truly per-box.
- **`hardware-configuration.nix`** — generated; the installer overwrites it from `/mnt` so I do not copy paths by hand.
- **`_templates/`** — reference `default.nix` if I bring my own host tree and still want disko in the flake.

If you fork this, rename hosts, add yours, and point `registry.nix` at your user under `users/`.
