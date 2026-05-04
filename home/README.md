# Home Manager

Everything here is **userland**: programs, dotfiles, desktop snippets.

- **`programs/`** — grouped in `programs/groups/` (`core`, `development`, `leisure`, `network`, `hardware`). Flip imports in `programs/default.nix` if you want less stuff.
- **`desktop/`** — BSPWM / Niri bits.
- **`shell/`** — zsh, terminals.
- **`core.nix`** — baseline `home.*` options.

Static files live in repo-root **`config/`** (not under `home/`).
