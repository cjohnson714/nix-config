{ pkgs, ... }:
{
  # Desktop utilities commonly used with BSPWM
  environment.systemPackages = with pkgs; [
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
