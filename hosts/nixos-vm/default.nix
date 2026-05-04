{ ... }:
{
  imports = [
    ../../nixos/modules
    ../../nixos/modules/desktop/window-managers/bspwm
    ../../nixos/modules/desktop/window-managers/niri

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
