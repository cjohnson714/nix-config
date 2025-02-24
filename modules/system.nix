{
  pkgs,
  lib,
  username,
  ...
}:

{
  # Shared System Configuration Module
  # Defines shared services, programs, and settings for all hosts.
  # User-specific programs are managed via home-manager configurations.

  # ==========================================================================
  #                                     Kernel
  # ==========================================================================

  boot.kernelPackages = pkgs.linuxPackages_cachyos; # CachyOS Kernel

  # SCX (Systemd Control) - Related to kernel and system management
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    package = pkgs.scx_git.full; # Use most up-to-date scheduler
  };

  # ==========================================================================
  #                               User Configuration
  # ==========================================================================

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ]; # Standard desktop groups
    shell = pkgs.zsh; # Use Zsh
  };

  nix.settings.trusted-users = [ username ]; # Allow user to specify additional substituters

  # ==========================================================================
  #                               Nix Configuration
  # ==========================================================================

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ]; # Enable Nix flakes

    substituters = [
      "https://cache.nixos.org"
      "https://chaotic-nyx.cachix.org"
      "https://catppuccin.cachix.org"
    ]; # Use official Nix cache

    trusted-public-keys = [
      # Included for reference (commented out)
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8"
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];

    builders-use-substitutes = true; # Use substitutes
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Delete old packages
  };

  nixpkgs.config.allowUnfree = true; # Allow non-free software

  # ==========================================================================
  #                             System Configuration
  # ==========================================================================

  time.timeZone = "US/Eastern";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    # Additional locale settings (if needed)
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  catppuccin = {
    enable = true;
    accent = "mauve";
    flavor = "mocha";
    tty.enable = true;
    cache.enable = true;
  };

  services.printing.enable = true; # Enable printing (CUPS)

  # ==========================================================================
  #                                    Fonts
  # ==========================================================================

  fonts = {
    packages = with pkgs; [
      # Install custom fonts
      font-awesome
      vistafonts
      material-design-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.symbols-only
      roboto
      roboto-mono
      inter
      maple-mono.TTF
      maple-mono.NF
      maple-mono.NFCN
      apple-fonts
    ];

    enableDefaultPackages = false; # Disable default font packages

    fontconfig.defaultFonts = {
      # Set default font families
      serif = [
        "New York"
        "Noto Serif"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "SF Pro"
        "Noto Sans"
        "Noto Color Emoji"
      ];
      monospace = [
        "Maple Mono NF CN"
        "Caskaydia Cove Nerd Font"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };

    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      antialias = true;
    };

  };

  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    GDK_USE_XFT = "1";
    QT_XFT = "true";
    XFT_SUBPIXEL = "rgb";
  };
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_CONTENT_SANDBOX = "1";
  };
  services.xserver.dpi = 96;

  # ==========================================================================
  #                           Programs and Services
  # ==========================================================================

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
  };

  networking.firewall.enable = false; # Disable firewall (configure ports as needed)

  services.openssh = {
    # SSH server config
    enable = true;
    settings = {
      X11Forwarding = true; # Enable X11 forwarding
      PermitRootLogin = "no"; # Disallow root login
      PasswordAuthentication = false; # Disable password auth
    };
    openFirewall = true; # Open SSH port in firewall
  };

  environment.systemPackages = with pkgs; [
    # System packages
    easyeffects
    fastfetch
    git
    lm_sensors
    libsecret
    ncdu
    nixfmt-rfc-style
    nnn
    scrot
    sysstat
    tree
    vim
    wget
    xfce.thunar
  ];

  services = {
    pulseaudio.enable = false; # Disable PulseAudio
    power-profiles-daemon.enable = true;
    dbus.packages = [ pkgs.gcr ];
    udisks2.enable = true;
    geoclue2.enable = true;

    gnome.gnome-keyring.enable = true;

    pipewire = {
      # PipeWire audio server
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      # media-session.enable = true; # Enabled by default
    };

    udev.packages = with pkgs; [ pkgs.gnome-settings-daemon ]; # Hardware integration
  };

  security = {
    polkit.enable = true;
    pam.services.ly.enableGnomeKeyring = true; # LY integration
    rtkit.enable = true;
  };
}
