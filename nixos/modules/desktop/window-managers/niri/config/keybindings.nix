{ pkgs, ... }:
{
  # Niri keybindings and input configuration
  environment.systemPackages = with pkgs; [
    # Input tools
    wl-clipboard
  ];

  # Niri configuration
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "us";
          variant = "";
          options = [
            "caps:ctrl_modifier"
            "grp:alt_shift_toggle"
          ];
        };
      };
      
      mouse = {
        natural-scroll = true;
        accel-speed = 0.5;
      };
      
      touchpad = {
        natural-scroll = true;
        accel-speed = 0.5;
        tap-to-click = true;
        click-method = "clickfinger";
        scroll-method = "two-finger";
      };
    };

    outputs = {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
      };
    };

    layout = {
      gaps = 8;
      border.width = 2;
      focus-ring.width = 2;
    };

    prefer-no-csd = true;
  };

  # Clipboard configuration
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
