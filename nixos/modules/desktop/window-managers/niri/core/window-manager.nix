{ pkgs, ... }:
{
  # Niri window manager configuration
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Display manager configuration for Niri
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };
}
