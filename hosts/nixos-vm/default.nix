{ ... }:
{
  imports = [
    ../../nixos/modules/system
    ../../nixos/modules/bspwm.nix
    ../../nixos/modules/niri.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    systemd-boot.enable = true;
  };
}
