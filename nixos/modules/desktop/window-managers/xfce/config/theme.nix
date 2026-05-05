{ pkgs, ... }:
{
  # XFCE-specific theme configuration
  imports = [ ../../shared ];

  # Note: XFCE theme settings should be configured in Home Manager using xfconf.settings
  # or via a user activation script using xfconf-query

  # XFCE-specific theme tools
  environment.systemPackages = with pkgs; [
    xfce.xfce4-settings
    nwg-look
    adw-gtk3
  ];
}
