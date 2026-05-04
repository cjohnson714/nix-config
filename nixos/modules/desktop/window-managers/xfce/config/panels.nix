{ pkgs, ... }:
{
  # XFCE panel configuration
  environment.systemPackages = with pkgs; [
    xfce.xfce4-panel
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-battery-plugin
  ];

  # XFCE panel settings
  xfconf.settings = {
    panels = {
      "panel-1" = {
        "position" = "p=6;x=0;y=0";
        "length" = "100";
        "positionx" = "0";
        "positiony" = "0";
        "size" = "30";
        "plugin-ids" = "1,2,3,4,5,6,7,8,9,10";
        "disable-struts" = false;
      };
    };

    plugins = {
      "plugin-1" = {
        type = "launcher";
        "button-style" = "2";
        "show-button-title" = false;
        "move-first" = false;
        "show-tooltip" = true;
        "item-list" = "firefox.desktop,xfce4-terminal-emulator.desktop,thunar.desktop";
      };

      "plugin-2" = {
        type = "tasklist";
        "grouping" = false;
        "show-handle" = false;
        "show-labels" = true;
        "show-preview" = true;
      };

      "plugin-3" = {
        type = "separator";
        "expand" = true;
        "style" = "0";
      };

      "plugin-4" = {
        type = "systray";
        "names-hidden" = false;
        "show-frames" = false;
        "size-max" = "32";
        "square-icons" = false;
      };

      "plugin-5" = {
        type = "pulseaudio";
        "enable-keyboard-shortcuts" = true;
        "show-osd" = true;
        "mute-on-middle-click" = true;
      };

      "plugin-6" = {
        type = "notification";
        "size-max" = "32";
        "mouse-left-click" = "default";
        "mouse-middle-click" = "default";
        "mouse-right-click" = "default";
      };

      "plugin-7" = {
        type = "power-manager-plugin";
      };

      "plugin-8" = {
        type = "clock";
        "mode" = "2";
        "digital-format" = "%R";
        "tooltip-format" = "%A %d %B %Y";
        "show-frame" = false;
      };

      "plugin-9" = {
        type = "separator";
        "expand" = false;
        "style" = "0";
      };

      "plugin-10" = {
        type = "actions";
        "appearance" = "0";
        "items" = "logout,lock,suspend,hibernate,reboot,shutdown";
      };
    };
  };
}
