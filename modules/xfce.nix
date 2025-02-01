{ pkgs, ... }:
{
  # bspwm related options
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.displayManager = {
    defaultSession = "none+xfce";
    ly.enable = true;
  };
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };

    displayManager = {
      lightdm.enable = false;
      gdm.enable = false;
    };
    windowManager.bspwm = {
      enable = false;
    };

    /*
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi # application launcher, the same as dmenu
          dunst # notification daemon
          i3blocks # status bar
          i3lock # default i3 screen locker
          xautolock # lock screen after some time
          i3status # provide information to i3bar
          i3-gaps # i3 with gaps
          picom # transparency and shadows
          feh # set wallpaper
          acpi # battery information
          arandr # screen layout manager
          dex # autostart applications
          xbindkeys # bind keys to commands
          xorg.xbacklight # control screen brightness
          xorg.xdpyinfo # get screen information
          sysstat # get system information
        ];
      };
    */

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };
  environment.systemPackages = with pkgs; [
    rofi
    dunst
    sxhkd
    udiskie
    xsettingsd
    feh
    wmname
    dex
    arandr
  ];
  programs.thunar.enable = true;
  # thunar file manager(part of xfce) related options
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  services.udisks2.enable = true;
  services.accounts-daemon.enable = true;
  services.libinput.enable = true;
}
