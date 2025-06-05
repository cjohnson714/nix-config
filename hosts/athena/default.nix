{ config, pkgs, ... }:

{
  # NixOS System Configuration

  imports = [
    ../../modules/system.nix
    ../../modules/bspwm.nix
    #../../modules/xfce.nix  # Optional: XFCE module (commented out)

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

  boot.initrd.luks.devices."luks-f274972b-bd67-4560-a219-726ece6cd396".keyFile = "/boot/crypto_keyfile.bin";


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
  
  # =========================================================================
  #                                 Monitors
  # =========================================================================



  # =========================================================================
  #                               System Configuration
  # =========================================================================

  system.stateVersion = "25.05"; # NixOS release version (do not change unless you understand the implications)
}
