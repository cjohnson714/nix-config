{ pkgs, ... }:
{
  # Niri compositor configuration via Home Manager.
  # We manage Niri as a package plus a KDL config file under
  # ~/.config/niri/config.kdl. This config only sets up outputs/monitors
  # to mirror your bspwm/xrandr layout. Keybinds are left at Niri defaults.

  home.packages = [ pkgs.niri ];

  home.file.".config/niri/config.kdl" = {
    text = ''
// Niri config for integrus, managed by Home Manager.
// Outputs configured to roughly match your bspwm monitor layout.
// Keybindings are left at Niri defaults.

output "DP-4" {
  // Primary 2560x1440 monitor at 143.96 Hz in X, placed above your lower row
  // In Niri, we only specify resolution so it can pick the best refresh rate.
  mode "2560x1440"
  position x=1920 y=1080
}

output "HDMI-0" {
  // 1920x1080 monitor at the lower-left
  mode "1920x1080"
  position x=0 y=1260
}

output "DP-0" {
  // 1920x1080 monitor at the upper-middle
  mode "1920x1080"
  position x=2240 y=0
}

output "DP-2" {
  // 1920x1080 monitor at the lower-right
  mode "1920x1080"
  position x=4480 y=1260
}

// If any of these outputs are not connected under Wayland, Niri will just
// ignore their sections. To confirm the exact connector names and modes,
// run `niri msg outputs` from inside a Niri session and update the names/
// modes above if needed.
'';
  };
}
