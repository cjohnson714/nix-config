{ pkgs, ... }:
{
  # Boot loader configuration
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    
    timeout = 5;
    
    # Enable systemd-boot by default
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    
    # GRUB configuration (can be overridden per-host)
    grub = {
      enable = false;
      device = "/dev/sda";
      useOSProber = true;
      enableCryptodisk = false;
    };
  };
}
