# Shared NixOS module list for all hosts. Imported from flake.nix.
{ inputs, system }:
[
  { nixpkgs.hostPlatform = system; }

  inputs.catppuccin.nixosModules.catppuccin
]
