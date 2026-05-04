{ ... }:
{
  imports = [
    ../security/baseline.nix
    ./kernel.nix
    ./nix-user.nix
    ./locale-theme.nix
    ./network.nix
    ./udev.nix
    ./services-core.nix
    ./systemd.nix
    ./fonts.nix
    ./environment.nix
    ./programs.nix
    ./security.nix
    ./xserver.nix
  ];
}
