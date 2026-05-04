/**
  Central host registry: one attrset, one entry per `nixosConfigurations.<name>`.

  Fields:
  - `system` — nixpkgs system string.
  - `username` — primary user (must match `users/<name>/` layout for now).
  - `hostname` — optional; defaults to the attr name (flake output key).
  - `platform` — `desktop` | `laptop` | `vm` | `raspberry` → `nixos/profiles/platform/<name>.nix`.
  - `gpu` — `none` | `nvidia` | `amdgpu` | `intel` | `qemu` → `nixos/profiles/gpu/<name>.nix`.
  - `host` — path to the host folder (imports `default.nix` + machine-specific boot, disko, etc.).
  - `extraModules` — optional list of extra NixOS modules.
  - `homeImports` — optional extra Home Manager modules for `users.<username>` (paths or inline modules).

  Optional merge: copy `registry.local.nix.example` to `registry.local.nix` (gitignored) to add
  hosts or shadow entries with `//` (replace whole host attrsets for overrides).
*/
let
  localPath = ./registry.local.nix;
  local = if builtins.pathExists localPath then import localPath else { };
  base = {
    athena = {
      system = "x86_64-linux";
      username = "integrus";
      platform = "desktop";
      gpu = "nvidia";
      host = ./athena;
    };

    nixos-vm = {
      system = "x86_64-linux";
      username = "integrus";
      platform = "vm";
      gpu = "qemu";
      host = ./nixos-vm;
    };
  };
in
base // local
