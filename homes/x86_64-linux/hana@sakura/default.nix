{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # CLI tools
    ../../../modules/home/cli/alacritty
    ../../../modules/home/cli/archives
    ../../../modules/home/cli/bat
    ../../../modules/home/cli/btop
    ../../../modules/home/cli/eza
    ../../../modules/home/cli/fuzzel
    ../../../modules/home/cli/graphviz
    ../../../modules/home/cli/htop
    ../../../modules/home/cli/jq
    ../../../modules/home/cli/libnotify
    ../../../modules/home/cli/ssh
    ../../../modules/home/cli/tmux
    ../../../modules/home/cli/wl-gammactl
    ../../../modules/home/cli/xdg-utils

    # Browsers
    ../../../modules/home/browser/firefox
    ../../../modules/home/browser/floorp
    ../../../modules/home/browser/zen-browser

    # Media
    ../../../modules/home/media/easyeffects
    ../../../modules/home/media/ffmpeg
    ../../../modules/home/media/imv
    ../../../modules/home/media/mpv
    ../../../modules/home/media/pavucontrol
    ../../../modules/home/media/playerctl
    ../../../modules/home/media/playerctld
    ../../../modules/home/media/pulsemixer
    ../../../modules/home/media/spotify

    # Wayland/Shell
    ../../../modules/home/wayland/niri
  ];

  # Git configuration
  programs.git.settings.user = {
    name = "cjohnson714";
    email = "cjohnson714@gmail.com";
  };

  # Enable noctalia-shell desktop shell
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        density = "compact";
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "Clock"; }
            { id = "SystemMonitor"; }
          ];
          center = [
            { id = "Workspace"; hideUnoccupied = false; labelMode = "none"; }
          ];
          right = [
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "ControlCenter"; }
          ];
        };
      };
      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
      };
      general = {
        lockOnSuspend = true;
        enableShadows = true;
        enableBlurBehind = true;
      };
      notifications = {
        enabled = true;
        location = "top_right";
      };
      osd = {
        enabled = true;
        location = "top_right";
      };
    };
  };

  # Spawn noctalia-shell on niri startup
  programs.niri.settings.spawn-at-startup = [
    { command = [ "noctalia-shell" ]; }
  ];

  # Additional packages specific to sakura
  home.packages = with pkgs; [
    # System utilities
    nvidia-system

    # Development
    git
    gh

    # Gaming
    mangohud
    gamemode

    # Wayland utilities
    wl-clipboard
    grim
    slurp
    swappy

    # File management
    yazi
    fd
    ripgrep
    fzf

    # Communication
    discord
    telegram-desktop

    # Office
    obsidian
  ];

  home.stateVersion = "25.05";
}
