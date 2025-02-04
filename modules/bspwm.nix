{ pkgs, ... }:
{

  # bspwm Configuration Module
  # Defines shared services, programs, and settings for a bspwm setup.
  # Window manager configuration is handled separately.

  # ==========================================================================
  #                               Display and Window Management
  # ==========================================================================

  environment.pathsToLink = [ "/libexec" ]; # Link /libexec from derivations

  services = {
    displayManager = {
      defaultSession = "none+bspwm"; # Start bspwm directly
      ly = {
        # Configure LY display manager
        enable = true;
        settings = {
          animation = "matrix"; # LY animation style
        };
      };
    };

    xserver = {
      enable = true;

      desktopManager = {
        xterm.enable = false; # Disable default xterm
        runXdgAutostartIfNone = true; # Autostart XDG apps (no DE)
      };

      windowManager.bspwm = {
        enable = true; # Enable bspwm
      };

      xkb = {
        layout = "us"; # Keyboard layout
        variant = ""; # Keyboard variant.
      };

      updateDbusEnvironment = true; # Ensure D-Bus environment variables are updated for X server sessions, allowing applications to communicate over D-Bus.
    };

    xrdp.defaultWindowManager = "bspwm";

    # System services
    accounts-daemon.enable = true;
    gvfs.enable = true;
    libinput.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  # ==========================================================================
  #                               System Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # bspwm and related tools
    acpi
    arandr
    dex
    feh
    ffmpegthumbnailer
    gnome-themes-extra
    imagemagick
    libinput
    lxappearance
    lxqt.lxqt-policykit
    polybar
    rofi
    sxhkd
    sysstat
    udiskie
    wmname
    xbindkeys
    xclip
    xdg-desktop-portal-gtk
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
      # Thunar configuration
      enable = true;
      plugins = with pkgs.xfce; [
        # Thunar plugins
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    xfconf.enable = true; # Enable Xfconf for persistent Thunar settings
  };

  # ==========================================================================
  #                               XDG Portal
  # ==========================================================================

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
  };
}
