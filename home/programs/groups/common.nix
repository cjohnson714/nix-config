{
  lib,
  pkgs,
  username,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    # Archives
    zip
    unzip
    p7zip

    # System utilities
    htop
    libnotify
    xdg-utils
    graphviz

    # Development tools
    vscode

    # Display utilities
    wl-gammactl
  ];

  programs = {
    # Terminal multiplexer
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = "mouse on";
    };

    # Enhanced cat
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    # Terminal emulators
    alacritty.enable = true;
    fuzzel.enable = true;

    # System monitors
    btop.enable = true;
    eza.enable = true;
    jq.enable = true;

    # SSH client
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519";
          extraOptions = {
            "AddKeysToAgent" = "yes";
          };
        };
      };
    };

    # Nix helper
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "${config.home.homeDirectory}/nix-config";
    };
  };

  services = {
    # Disk mounting service
    udiskie = {
      enable = true;
      tray = "never";
    };

    # X11 settings daemon
    xsettingsd = {
      enable = true;
      settings = {
        "Xft/Antialias" = true;
        "Xft/Hinting" = true;
        "Xft/HintStyle" = "hintslight";
        "Xft/DPI" = 98304;
        "Xft/lcdfilter" = "lcddefault";
        "Xft/RGBA" = "rgb";
        "EnableInputFeedbackSounds" = false;
        "Net/EnableEventSounds" = true;
      };
    };
  };

  # GTK configuration
  gtk = {
    enable = true;
    font = {
      name = "SF Pro";
      size = 10;
    };
  };

  # Catppuccin theme
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
    enable = true;
    cache.enable = true;
    gtk.icon.enable = true;
    cursors.enable = true;
    btop.enable = true;
    bat.enable = true;
    fzf.enable = true;
    kitty.enable = true;
    mpv.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
