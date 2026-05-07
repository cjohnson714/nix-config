{
  config,
  pkgs,
  ...
}:

{
  # NixOS System Configuration

  imports = [
    ../../../modules/system

    ../../../modules/niri.nix

    ./hardware-configuration.nix
  ];

  # =========================================================================
  #                               Bootloader
  # =========================================================================

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    systemd-boot.enable = true;
  };

  # =========================================================================
  #                               Networking
  # =========================================================================

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  # =========================================================================
  #                               Virtualization (QEMU)
  # =========================================================================

  services.xserver.videoDrivers = [ "qxl" ];
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;

  # =========================================================================
  #                               System Configuration
  # =========================================================================

  system.stateVersion = "25.05";
}
