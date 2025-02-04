{ pkgs, ... }:
{
  # ==========================================================================
  #                               Display and Window Management
  # ==========================================================================
  services = {
    displayManager = {
      defaultSession = "none+bspwm"; # Start bspwm directly
      ly = {
        enable = true; # Enable LY display manager
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
        variant = ""; # Keyboard variant
      };

      updateDbusEnvironment = true; # Ensure D-Bus environment variables are updated for X server sessions
    };

    xrdp.defaultWindowManager = "bspwm"; # Set default window manager for xrdp

    # ==========================================================================
    #                               System Services
    # ==========================================================================

    accounts-daemon.enable = true; # Manage user accounts
    gvfs.enable = true; # Virtual filesystem for GIO
    libinput.enable = true; # Input device management
    tumbler.enable = true; # Thumbnail generation
    udisks2.enable = true; # Disk management service
    upower.enable = true; # Power management
    greenclip.enable = true; # Clipboard manager
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
    polybar
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
      enable = true; # Enable Thunar
      plugins = with pkgs.xfce; [
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
    enable = true; # Enable XDG portal
    xdgOpenUsePortal = true; # Use XDG portal for opening files
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
  environment.pathsToLink = [ "/libexec" ]; # Link /libexec from derivations
}
