# Shared NixOS module list for all hosts. Imported from flake.nix.
{ inputs, username, system }:
let
  userModule = ../modules/users + "/${username}.nix";
in
[
  { nixpkgs.hostPlatform = system; }

  userModule

  inputs.catppuccin.nixosModules.catppuccin

  {
    nixpkgs.overlays = [
      (import ../overlays/custom-packages.nix)
    ];
  }
]
