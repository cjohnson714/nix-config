{ config, pkgs, ... }:

{
  # NixOS System Configuration

  imports = [
    ../../modules/system.nix
    ../../modules/bspwm.nix
    #../../modules/xfce.nix

    ../../modules/niri.nix

    ./hardware-configuration.nix
  ];

  # =========================================================================
  #                               Bootloader
  # =========================================================================

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sdc";
      useOSProber = true;
      enableCryptodisk = true;
    };
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };

  boot.initrd.luks.devices."luks-f274972b-bd67-4560-a219-726ece6cd396".keyFile =
    "/boot/crypto_keyfile.bin";

  # =========================================================================
  #                               Networking
  # =========================================================================

  networking.hostName = "athena";
  networking.networkmanager.enable = true;

  # =========================================================================
  #                                 NVIDIA
  # =========================================================================

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # fix black screen on boot with nvidia, fix console output
  boot.kernelParams = [
    "nvidia-drm.fbdev=0"
    "video=DP-3:2560x1440@144"
    "video=DP-1:d"
    "video=DP-2:d"
    "video=HDMI-A-1:d"
  ];

  # =========================================================================
  #                                 Monitors
  # =========================================================================
  # sddm for just main monitor
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm/.config 0711 sddm sddm -"
    "f /var/lib/sddm/.config/weston.ini 0644 sddm sddm - [core]\nshell=desktop-shell.so\n\n[output]\nname=DP-3\nmode=2560x1440@143.96\nprimary=true\n\n[output]\nname=DP-1\nmode=off\n\n[output]\nname=DP-2\nmode=off\n\n[output]\nname=HDMI-A-1\nmode=off"
  ];

  # =========================================================================
  #                               System Configuration
  # =========================================================================

  system.stateVersion = "25.05";
}
