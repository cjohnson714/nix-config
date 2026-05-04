{ ... }:
{
  imports = [
    ../../nixos/modules
    ../../nixos/modules/desktop/window-managers/niri

    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sdc";
      useOSProber = true;
      enableCryptodisk = true;
    };
  };

  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };

  boot.initrd.luks.devices."luks-f274972b-bd67-4560-a219-726ece6cd396".keyFile =
    "/boot/crypto_keyfile.bin";

  # Display configuration for multi-monitor setup
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm/.config 0711 sddm sddm -"
    "f /var/lib/sddm/.config/weston.ini 0644 sddm sddm - [core]\nshell=desktop-shell.so\n\n[output]\nname=DP-3\nmode=2560x1440@143.96\nprimary=true\n\n[output]\nname=DP-1\nmode=off\n\n[output]\nname=DP-2\nmode=off\n\n[output]\nname=HDMI-A-1\nmode=off"
  ];

  # Host-specific configuration
  networking.hostName = "athena";
  
  # Enable hardware-specific optimizations
  hardware.enableAllFirmware = true;
  
  # Performance optimizations
  nix.settings = {
    cores = 0;  # Use all available cores
    max-jobs = "auto";
    sandbox = true;
  };
}
