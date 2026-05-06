{
  lib,
  pkgs,
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

    wl-gammactl
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

    alacritty.enable = true;
    fuzzel.enable = true;

    btop.enable = true;
    eza.enable = true;
    jq.enable = true;
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
