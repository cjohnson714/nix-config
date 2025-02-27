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

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.page-cluster" = 0;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_writeback_centisecs" = 1500;
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.printk" = "3 3 3 3";
    "kernel.kptr_restrict" = 2;
    "kernel.kexec_load_disabled" = 1;
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
    "fs.xfs.xfssyncd_centisecs" = 10000;
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
  #                               Network Configuration
  # ==========================================================================
  services.resolved.enable = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  networking.firewall.enable = false; # Disable firewall (configure ports as needed)

  # ==========================================================================
  #                               Udev Configuration
  # ==========================================================================
  services.udev = {
    packages = [ pkgs.gnome-settings-daemon ];
    extraRules = ''
      TEST!="/dev/zram0", GOTO="zram_end"
      SYSCTL{vm.swappiness}="150"
      LABEL="zram_end"

      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"

      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
      ATTR{link_power_management_policy}=="*", \
      ATTR{link_power_management_policy}="max_performance"

      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
      ATTR{queue/scheduler}="bfq"

      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
      ATTR{queue/scheduler}="mq-deadline"

      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
      ATTR{queue/scheduler}="none"

      ACTION=="add|bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
      ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
      TEST=="power/control", ATTR{power/control}="auto"

      ACTION=="remove|unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
      ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
      TEST=="power/control", ATTR{power/control}="on"

      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"

      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
      RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"

      SUBSYSTEM=="block", TEST!="${pkgs.ntfs3g}/bin/ntfs-3g", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"
    '';
  };
  # ==========================================================================
  #                               System Services
  # ==========================================================================
  services = {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      package = pkgs.scx_git.full; # Use most up-to-date scheduler
    };

    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
      ];
      fallbackServers = [
        "time.google.com"
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };

    zram-generator = {
      enable = true;
      settings.zram0 = {
        compression-algorithm = "zstd lz4 (type=huge)";
        zram-size = "ram";
        swap-priority = 100;
        fs-type = "swap";
      };
    };

    openssh = {
      # SSH server config
      enable = true;
      settings = {
        X11Forwarding = true; # Enable X11 forwarding
        PermitRootLogin = "no"; # Disallow root login
        PasswordAuthentication = false; # Disable password auth
      };
      openFirewall = true; # Open SSH port in firewall
    };

    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=50M
      MaxFileSec=1day
    '';

    power-profiles-daemon.enable = true;
    dbus.packages = [ pkgs.gcr ];
    udisks2.enable = true;
    geoclue2.enable = true;

    gnome.gnome-keyring.enable = true;

    pulseaudio.enable = false; # Disable PulseAudio

    pipewire = {
      # PipeWire audio server
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      # media-session.enable = true; # Enabled by default
    };
  };

  # ==========================================================================
  #                               systemd Configuration
  # ==========================================================================
  systemd = {
    extraConfig = ''
      DefaultTimeoutStartSec=15s
      DefaultTimeoutStopSec=10s
      DefaultLimitNOFILE=2048:2097152
    '';

    user.extraConfig = ''
      DefaultLimitNOFILE=1024:1048576
    '';

    tmpfiles.rules = [
      "d /var/lib/systemd/coredump 755 root root 3d"
      "w! /sys/module/zswap/parameters/enabled - - - - N"
      "w! /sys/class/rtc/rtc0/max_user_freq - - - - 3072"
      "w! /proc/sys/dev/hpet/max-user-freq  - - - - 3072"
      "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
      "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    ];

    services = {
      "rtkit-daemon".serviceConfig.LogLevelMax = "info";
      "user@.service".serviceConfig.Delegate = "cpu cpuset io memory pids";
    };
  };

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
  # ==========================================================================
  #                               Environment Configuration
  # ==========================================================================
  environment = {
    systemPackages = with pkgs; [
      # System packages
      easyeffects
      fastfetch
      git
      hdparm
      lm_sensors
      libsecret
      ncdu
      nixfmt-rfc-style
      nnn
      ntfs3g
      scrot
      sysstat
      tree
      vim
      wget
      xfce.thunar
    ];

    variables = {
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
      GDK_USE_XFT = "1";
      QT_XFT = "true";
      XFT_SUBPIXEL = "rgb";
    };

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DISABLE_CONTENT_SANDBOX = "1";
    };
  };

  # ==========================================================================
  #                               Programs Configuration
  # ==========================================================================
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
  };

  # ==========================================================================
  #                               X Server Configuration
  # ==========================================================================
  services.xserver.dpi = 96;

  # ==========================================================================
  #                               Security Configuration
  # ==========================================================================
  security = {
    polkit.enable = true;
    pam.services.ly.enableGnomeKeyring = true; # LY integration
    rtkit.enable = true;
  };
}
