{ pkgs, ... }:
{
  # XFCE autostart applications and services
  environment.systemPackages = with pkgs; [
    # Autostart tools
    dex
  ];

  # XFCE autostart configuration
  environment.etc."xdg/autostart/xfce4-settings-autostart.desktop".source = pkgs.writeText "xfce4-settings-autostart.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=XFCE Settings Daemon
    Exec=xfce4-settings-helper
    OnlyShowIn=XFCE;
    StartupNotify=false
    Terminal=false
    Hidden=false
  '';

  # Systemd user services for XFCE
  systemd.user.services = {
    # Wallpaper service
    xfce-wallpaper = {
      Unit = {
        Description = "Set wallpaper for XFCE";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.xfce.xfce4-settings}/bin/xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/nixos-wallpaper.png";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Notification daemon
    xfce-notifications = {
      Unit = {
        Description = "Notification daemon for XFCE";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.xfce.xfce4-notifyd}/bin/xfce4-notifyd";
        Restart = "always";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Power manager
    xfce-power-manager = {
      Unit = {
        Description = "Power manager for XFCE";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.xfce.xfce4-power-manager}/bin/xfce4-power-manager";
        Restart = "always";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  # Environment variables for XFCE
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "XFCE";
  };
}
