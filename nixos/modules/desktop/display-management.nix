{ pkgs, ... }:
{
  # Display server configuration
  services = {
    displayManager = {
      # SDDM display manager
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-macchiato";
      };
    };

    xserver = {
      enable = true;
      
      # Desktop manager
      desktopManager = {
        xterm.enable = false;
        runXdgAutostartIfNone = true;
      };
      
      # XKB configuration
      xkb = {
        layout = "us";
        variant = "";
        options = [
          "caps:ctrl_modifier"
          "grp:alt_shift_toggle"
        ];
      };
      
      # Update DBus environment
      updateDbusEnvironment = true;
      
      # DPI configuration
      dpi = 96;
    };
  };

  # XDG portal configuration
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
  };
}
