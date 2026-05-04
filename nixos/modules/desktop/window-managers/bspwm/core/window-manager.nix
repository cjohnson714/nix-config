{ pkgs, ... }:
{
  # BSPWM window manager configuration
  services.xserver.windowManager.bspwm = {
    enable = true;
  };

  # Set BSPWM as default session when BSPWM is the primary window manager
  services.displayManager.defaultSession = "none+bspwm";

  # Remote desktop configuration
  services.xrdp.defaultWindowManager = "bspwm";

  # Environment paths for BSPWM
  environment.pathsToLink = [ "/libexec" ];
}
