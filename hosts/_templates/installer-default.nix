/**
  Reference copy of what `install/bootstrap.sh` writes for stacked installs (fragment optional).
  Use as inspiration when you bring your own `hosts/<name>/` directory (`HOST_MODULE` as a folder).
*/
{ inputs, lib, ... }:
{
  imports =
    [
      inputs.disko.nixosModules.disko
      ../../nixos/modules/system
      ../../nixos/modules/niri.nix
      ./hardware-configuration.nix
      ./disko-scheme.nix
    ]
    ++ lib.optional (builtins.pathExists ./host-fragment.nix) ./host-fragment.nix;
}
