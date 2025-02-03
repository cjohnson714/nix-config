{
  lib,
  pkgs,
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

    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn
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

    btop.enable = true; # replacement of htop/nmon
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    ssh = {
      enable = true;
      extraConfig = ''
        Host github.com
          IdentityFile ~/.ssh/id_ed25519
          AddKeysToAgent yes
      '';
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
        "Xft/HintStyle" = "hintfull";
        "Xft/DPI" = 98304;
        "Xft/lcdfilter" = "lcddefault";
        "Xft/RGBA" = "rgb";
        "EnableInputFeedbackSounds" = false;
        "Net/EnableEventSounds" = true;
      };
    };

    gnome-keyring.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      name = "Sans";
      size = 10;
    };
  };

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
    enable = true;
    cache.enable = true;
    gtk.enable = true;
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
