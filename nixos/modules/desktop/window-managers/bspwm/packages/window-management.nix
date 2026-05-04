{ pkgs, ... }:
{
  # Window management tools
  environment.systemPackages = with pkgs; [
    bspwm
    sxhkd
    rofi
    feh
    arandr
    xorg.xbacklight
    xorg.xdpyinfo
    xorg.xrandr
    xbindkeys
    xclip
    wmname
    xsettingsd
  ];
}
