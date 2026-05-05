{ pkgs, ... }:
{
  # XFCE panel configuration
  # Note: XFCE panel settings should be configured in Home Manager using xfconf.settings
  
  environment.systemPackages = with pkgs; [
    xfce.xfce4-panel
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-battery-plugin
  ];
}
