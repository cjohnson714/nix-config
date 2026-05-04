# Install scripts

I use these from the **NixOS live ISO** (root shell, flakes on, network up).

| Script | What it does |
|--------|----------------|
| **`curl-installer.sh`** | Shallow-clones the flake, then runs `bootstrap.sh`. I point the default clone at my repo so the quick summary turns on automatically (`NIX_CONFIG_UPSTREAM_DEFAULT`). |
| **`bootstrap.sh`** | Detects platform/GPU, optional one-screen confirm, disko, regenerates **`hardware-configuration.nix`** into `hosts/<name>/`, **`nixos-install`**. |
| **`refresh-hardware.sh`** | On an **already installed** system: regenerate `hardware-configuration.nix` from `/` and `nixos-rebuild` — when disk IDs changed and I do not want to edit files by hand. |
| **`lib/`** | `detect.sh`, `quickstart.sh`, `render_disko.py`, `common.sh`. |

**Environment knobs I actually use**

- `OWNER_QUICKSTART=0` — force the long questionnaire.
- `OWNER_DEFAULT_USERNAME`, `OWNER_DEFAULT_SCHEME` — override my baked-in defaults.
- `DISK`, `DISKO_SCHEME`, `FLAKE_HOST`, `PRESET=personal`, `INSTALL_*` — see the top comment in `bootstrap.sh`.
