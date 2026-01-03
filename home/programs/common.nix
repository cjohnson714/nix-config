{
  lib,
  pkgs,
  username,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    p7zip

    # utils
    htop

    # misc
    libnotify
    xdg-utils
    graphviz

    # IDE
    vscode

    # Wayland gamma control UI
    wl-gammactl

    #nodePackages_latest.nodejs
    #nodePackages.npm
    #nodePackages.pnpm
    #yarn
  ];

  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = "mouse on";
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    # Niri defaults expect these programs for Super+T (terminal) and
    # Super+D (launcher).
    alacritty.enable = true;
    fuzzel.enable = true;

    btop.enable = true; # replacement of htop/nmon
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor
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

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      # Point this to your config directory
      flake = "${config.home.homeDirectory}/nix-config";
    };
  };

  services = {
    udiskie = {
      enable = true;
      tray = "never";
    };

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

  gtk = {
    enable = true;
    font = {
      name = "SF Pro";
      size = 10;
    };
  };

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
    enable = true;
    cache.enable = true;
    #gtk.enable = true;
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
