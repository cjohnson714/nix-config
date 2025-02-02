{ pkgs, ... }:
{

  # Integrus Home Manager Configuration
  # This file imports and configures all home-manager modules.

  imports = [
    ../../home/core.nix # Core home-manager settings

    ../../home/programs # Shared program configurations
    ../../home/shell # Shell configurations

    ../../home/bspwm # bspwm-related configurations
    ../../home/dunst # Dunst notification daemon configuration
    ../../home/rofi # Rofi launcher configuration
    ../../home/polybar # Polybar config
  ];

  # ==========================================================================
  #                               Git Configuration
  # ==========================================================================

  programs.git = {
    userName = "cjohnson714";
    userEmail = "cjohnson714@gmail.com";
  };
}
