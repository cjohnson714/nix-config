{ pkgs, ... }:
{
  # Wayland compositor: niri
  # This enables the system-wide niri program so it can be used as a desktop session.

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
}
