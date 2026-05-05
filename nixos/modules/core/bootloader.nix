{ pkgs, lib, ... }:
{
  # Boot loader configuration
  boot.loader = {
    efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = lib.mkDefault "/boot";
    };
    
    timeout = lib.mkDefault 5;
    
    # Enable systemd-boot by default (can be overridden per-host)
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 10;
    };
    
    # GRUB configuration (can be overridden per-host)
    grub = {
      enable = lib.mkDefault false;
      device = lib.mkDefault "/dev/sda";
      useOSProber = lib.mkDefault true;
      enableCryptodisk = lib.mkDefault false;
    };
  };
}
