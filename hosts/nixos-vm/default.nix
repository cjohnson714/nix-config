{ config, pkgs, ... }:

{
  # NixOS System Configuration

  imports =
    [
      ../../modules/system.nix
      ../../modules/bspwm.nix
      #../../modules/xfce.nix  # Optional: XFCE module (commented out)

      ./hardware-configuration.nix # Hardware scan results
    ];

  # =========================================================================
  #                               Bootloader
  # =========================================================================

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot"; # Mount point for EFI system partition
    };
    systemd-boot.enable = true; # Use systemd-boot bootloader
  };

  # =========================================================================
  #                               Networking
  # =========================================================================

  networking.hostName = "nixos-vm"; # System hostname
  # networking.wireless.enable = true; # Enable wireless support (wpa_supplicant) - Optional

  # Network proxy configuration (if needed)
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true; # Enable NetworkManager
  # networking.defaultGateway = "192.168.5.201"; # Default gateway - Optional

  # =========================================================================
  #                               Virtualization (QEMU)
  # =========================================================================

  services.xserver.videoDrivers = [ "qxl" ]; # Video driver for QEMU
  services.qemuGuest.enable = true; # Enable QEMU guest services
  services.spice-vdagentd.enable = true; # Enable Spice vdagent
  services.spice-autorandr.enable = true; # Enable Spice autorandr

  # =========================================================================
  #                               System Configuration
  # =========================================================================

  system.stateVersion = "25.05"; # NixOS release version (do not change unless you understand the implications)
}