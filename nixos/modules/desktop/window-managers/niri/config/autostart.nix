{ pkgs, ... }:
{
  # Niri autostart applications and services
  environment.systemPackages = with pkgs; [
    # Autostart tools
    dms-shell
  ];

  # Systemd user services for Niri
  systemd.user.services = {
    # Wallpaper service
    niri-wallpaper = {
      Unit = {
        Description = "Set wallpaper for Niri";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i /usr/share/backgrounds/nixos-wallpaper.png";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Notification daemon
    niri-notifications = {
      Unit = {
        Description = "Notification daemon for Niri";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.dunst}/bin/dunst";
        Restart = "always";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Status bar (optional)
    niri-statusbar = {
      Unit = {
        Description = "Status bar for Niri";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.eww}/bin/eww open bar";
        Restart = "always";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  # Environment variables for Niri
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    NIXOS_OZONE_WL = "1";
  };
}
