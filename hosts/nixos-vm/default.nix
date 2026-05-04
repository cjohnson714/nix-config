{ ... }:
{
  imports = [
    ../../nixos/modules
    ../../nixos/modules/desktop/window-managers/bspwm.nix
    ../../nixos/modules/desktop/window-managers/niri.nix

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
