# Vendor- or GPU-specific home bits (e.g. nvidia dotfiles).
{ ... }:
{
  imports = [
    ./nvidia.nix
  ];
}
