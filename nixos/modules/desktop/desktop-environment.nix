{ pkgs, ... }:
{
  # Desktop environment services
  services = {
    # Desktop services
    accounts-daemon.enable = true;
    gvfs.enable = true;
    libinput.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    clipcat.enable = true;
    
    # Remote desktop service (window manager set by individual modules)
    xrdp.enable = false;
  };

  # Desktop utilities
  environment.systemPackages = with pkgs; [
    # Desktop utilities
    dex
    nwg-look
    xdg-user-dirs
    xdg-utils
    
    # System monitoring
    acpi
    sysstat
    udiskie
  ];
}
