{ pkgs, ... }: {

  # bspwm Configuration Module
  # Defines shared services, programs, and settings for a bspwm setup.
  # Window manager configuration is handled separately.

  # ==========================================================================
  #                               Display and Window Management
  # ==========================================================================

  environment.pathsToLink = [ "/libexec" ]; # Link /libexec from derivations

  services.displayManager = {
    defaultSession = "none+bspwm"; # Start bspwm directly
    ly = { # Configure LY display manager
      enable = true;
      settings = {
        animation = "matrix"; # LY animation style
      };
    };
  };

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false; # Disable default xterm
      runXdgAutostartIfNone = true; # Autostart XDG apps (no DE)
    };

    displayManager = { # Disable other display managers
      lightdm.enable = false;
      gdm.enable = false;
    };

    windowManager.bspwm = {
      enable = true; # Enable bspwm
    };

    xkb = {
      layout  = "us"; # Kayboard layout
      variant = ""; # Keyboard variant
    };
  };


  # ==========================================================================
  #                               System Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [ # bspwm and related tools
    acpi
    arandr
    dex
    feh
    ffmpegthumbnailer
    gnome-themes-extra
    imagemagick
    libinput
    lxappearance
    polkit_gnome
    rofi
    sxhkd
    sysstat
    udiskie
    wmname
    xbindkeys
    xclip
    xorg.xbacklight
    xorg.xdpyinfo
    xorg.xrandr
    xsettingsd
  ];


  # ==========================================================================
  #                               Thunar File Manager
  # ==========================================================================

  programs.thunar = { # Thunar configuration
    enable = true;
    plugins = with pkgs.xfce; [ # Thunar plugins
      thunar-archive-plugin
      thunar-volman
    ];
  };

  programs.xfconf.enable = true; # Enable Xfconf for persistent Thunar settings


  # ==========================================================================
  #                               System Services
  # ==========================================================================

  services = { # System services
    accounts-daemon.enable = true;
    gvfs.enable = true;
    libinput.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;
    xserver.updateDbusEnvironment = true; # Update X server's D-Bus environment
  };
}