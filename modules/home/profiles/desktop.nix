{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nix-config.profiles;
in
{
  config = mkIf cfg.desktop.enable {
    # Niri configuration
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    # Noctalia Shell configuration
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
  };
}
