{ pkgs, ... }:
{
  # BSPWM-specific system services
  services = {
    # Desktop services that BSPWM typically uses
    accounts-daemon.enable = true;
    gvfs.enable = true;
    libinput.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    clipcat.enable = true;
  };
}
