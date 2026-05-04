{ pkgs, ... }:
{
  # BSPWM-specific theme configuration
  imports = [ ../shared ];

  # BSPWM-specific theme tools
  environment.systemPackages = with pkgs; [
    nwg-look
    xsettingsd
  ];
}
