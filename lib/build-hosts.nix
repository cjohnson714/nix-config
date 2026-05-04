/**
  Expands `hosts/registry.nix` into `nixosConfigurations` by composing platform + GPU profiles
  and the per-host directory module (`host`).

  `platform` / `gpu` are string tags (see `install/lib/detect.sh`); Nix only maps tags to modules
  here — live hardware detection is done by the installer shell scripts.
*/
{ inputs, lib, flakeRoot }:
let
  mkNixos = import (flakeRoot + "/lib/mk-nixos.nix") inputs;

  registry = import (flakeRoot + "/hosts/registry.nix");

  profilePath =
    group: name:
    let
      p = flakeRoot + "/nixos/profiles/hardware/${group}/${name}.nix";
    in
    if builtins.pathExists p then p else null;

  platformModules =
    platform:
    let
      p = profilePath "platforms" platform;
    in
    if p == null then [ ] else [ p ];

  gpuModules =
    gpu:
    let
      p = profilePath "gpu" gpu;
      fallback = flakeRoot + "/nixos/profiles/hardware/gpu/none.nix";
    in
    if p != null then [ p ] else [ fallback ];

  mkConfig =
    name: cfg:
    let
      inherit (cfg) system username host;
      platform = cfg.platform or "desktop";
      gpu = cfg.gpu or "none";
      extra = cfg.extraModules or [ ];
      homeImports = cfg.homeImports or [ ];
    in
    mkNixos {
      inherit system username homeImports;
      modules =
        [
          { networking.hostName = lib.mkDefault (cfg.hostname or name); }
        ]
        ++ platformModules platform
        ++ gpuModules gpu
        ++ [ host ]
        ++ extra;
    };

  names = builtins.attrNames registry;
in
lib.genAttrs names (name: mkConfig name registry.${name})
