{ inputs, lib, ... }:
let
  flakeRoot = ../.;
in
{
  flake.nixosConfigurations = import ../lib/build-hosts.nix { inherit inputs lib flakeRoot; };
}
