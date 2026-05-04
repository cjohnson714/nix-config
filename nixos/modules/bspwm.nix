{ pkgs, ... }:
{
  # ==========================================================================
  #                               Display and Window Management
  # ==========================================================================
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };

      defaultSession = "none+bspwm";
    };

    xserver = {
      enable = true;

      desktopManager = {
        xterm.enable = false;
        runXdgAutostartIfNone = true;
      };

      windowManager.bspwm = {
        enable = true;
      };

      xkb = {
        layout = "us";
        variant = "";
      };

      updateDbusEnvironment = true;
    };

    xrdp.defaultWindowManager = "bspwm";

    # ==========================================================================
    #                               System Services
    # ==========================================================================
    accounts-daemon.enable = true;
    gvfs.enable = true;
    libinput.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    clipcat.enable = true;
  };

  # ==========================================================================
  #                               System Packages
  # ==========================================================================
  environment.systemPackages = with pkgs; [
    acpi
    arandr
    dex
    feh
    ffmpegthumbnailer
    gnome-themes-extra
    imagemagick
    libinput
    lxqt.lxqt-policykit
    nwg-look
    rofi
    sxhkd
    sysstat
    udiskie
    wmname
    xbindkeys
    xclip
    xdg-user-dirs
    xdg-utils
    xorg.xbacklight
    xorg.xdpyinfo
    xorg.xrandr
    xsettingsd
  ];

  # ==========================================================================
  #                               Thunar File Manager
  # ==========================================================================
  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    xfconf.enable = true;
  };

  # ==========================================================================
  #                               XDG Portal
  # ==========================================================================
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal
    ];
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
  };

  # ==========================================================================
  #                               Environment Paths
  # ==========================================================================
  environment.pathsToLink = [ "/libexec" ];
}
