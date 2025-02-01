{
  lib,
  pkgs,
  catppuccin-bat,
  ...
}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    p7zip

    # utils
    #ripgrep
    #yq-go # https://github.com/mikefarah/yq
    htop

    # misc
    libnotify
    #wineWowPackages.wayland
    xdg-utils
    graphviz

    # productivity
    #obsidian

    # IDE
    #insomnia
    vscode

    # cloud native
    #docker-compose
    #kubectl

    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn

    # db related
    #dbeaver-bin
    #mycli
    #pgcli
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
        theme = "catppuccin-mocha";
      };
      themes = {
        # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
        catppuccin-mocha = {
          src = catppuccin-bat;
          file = "Catppuccin-mocha.tmTheme";
        };
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
    aria2.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  services = {
    #syncthing.enable = true;

    # auto mount usb drives
    udiskie = {
      enable = true;
      tray = "never";
    };

    xsettingsd.enable = true;
    xsettingsd.settings = {
      "Xft/Antialias" = true;
      "Xft/Hinting" = true;
      "Xft/HintStyle" = "hintfull";
      "Xft/DPI" = 98304;
      "Xft/lcdfilter" = "lcddefault";
      "Xft/RGBA" = "rgb";
      "EnableInputFeedbackSounds" = false;
      "Net/EnableEventSounds" = true;
    };

    gnome-keyring.enable = true;
  };

  gtk = {
    enable = true;
    theme.package = pkgs.gruvbox-gtk-theme.override {
      colorVariants = [ "dark" ];
      themeVariants = [ "purple" ];
    };
    theme.name = "Gruvbox-Purple-Dark";

    iconTheme.package = pkgs.gruvbox-plus-icons;
    iconTheme.name = "Gruvbox-Plus-Dark";

    font.name = "Sans";
    font.size = 10;
  };
}
