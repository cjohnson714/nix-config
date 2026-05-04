{ pkgs, ... }:
{
  # XFCE desktop environment
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  # Environment paths for XFCE
  environment.pathsToLink = [ "/libexec" ];
}
