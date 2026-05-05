{ pkgs, ... }:
{
  # Shared theme configuration for all window managers
  # Note: GTK theming is handled in Home Manager, not NixOS system config
  
  # Qt theme configuration at system level
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Environment variables for consistent theming
  environment.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
    QT_QPA_PLATFORMTHEME = "gtk";
  };
}
