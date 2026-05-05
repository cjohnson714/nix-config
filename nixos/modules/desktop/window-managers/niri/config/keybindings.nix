{ pkgs, ... }:
{
  # Niri keybindings and input configuration
  # Note: Niri configuration via programs.niri.settings should be done in Home Manager
  # This file provides system-level support only
  
  environment.systemPackages = with pkgs; [
    # Input tools
    wl-clipboard
  ];

  # Clipboard configuration
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  
  # For niri configuration, add to your home configuration:
  # programs.niri.settings = { ... };
}
