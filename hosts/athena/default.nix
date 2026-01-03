{ config, pkgs, ... }:

{
  # NixOS System Configuration

  imports = [
    ../../modules/system.nix
    ../../modules/bspwm.nix
    #../../modules/xfce.nix  # Optional: XFCE module (commented out)

    ../../modules/niri.nix

    ./hardware-configuration.nix # Hardware scan results
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

  networking.hostName = "athena"; # System hostname
  # networking.wireless.enable = true; # Enable wireless support (wpa_supplicant) - Optional

  # Network proxy configuration (if needed)
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true; # Enable NetworkManager
  # networking.defaultGateway = "192.168.5.201"; # Default gateway - Optional

  # =========================================================================
  #                                 NVIDIA
  # =========================================================================

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ]; # Use NVIDIA driver

  hardware.nvidia = {
    modesetting.enable = true; # Enable modesetting for NVIDIA
    powerManagement.enable = false; # Disable power management for NVIDIA
    powerManagement.finegrained = false; # Disable fine-grained power management
    open = false; # Disable open source driver for NVIDIA
    nvidiaSettings = true; # Enable NVIDIA settings
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Use stable NVIDIA driver
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

  system.stateVersion = "25.05"; # NixOS release version (do not change unless you understand the implications)
}
