# Aggregated shared desktop configuration (see sibling .nix files).
{ ... }:
{
  imports = [
    ./kernel.nix
    ./users-nix.nix
    ./locale.nix
    ./theme.nix
    ./network.nix
    ./udev.nix
    ./services.nix
    ./systemd.nix
    ./fonts.nix
    ./environment.nix
    ./programs.nix
    ./security.nix
  ];
}
