{ pkgs, ... }:
{
  # XFCE-specific theme configuration
  imports = [ ../../shared ];

  # XFCE-specific theme tools
  environment.systemPackages = with pkgs; [
    xfce.xfce4-settings
    nwg-look
    adw-gtk3
  ];

  # XFCE-specific theme settings
  xfconf.settings = {
    xsettings = {
      "Gtk/ThemeName" = "Catppuccin-Mocha-Standard-Blue-Dark";
      "Gtk/IconThemeName" = "Papirus-Dark";
      "Gtk/CursorThemeName" = "Catppuccin-Mocha-Dark-Cursors";
      "Gtk/FontName" = "SF Pro 10";
      "Xft/Antialias" = true;
      "Xft/Hinting" = 1;
      "Xft/HintStyle" = "hintslight";
      "Xft/RGBA" = "rgb";
    };
    
    xfwm4 = {
      "general/theme" = "Catppuccin-Mocha-Standard-Blue-Dark";
      "general/title_font" = "SF Pro Bold 10";
      "general/button_layout" = "O|SHMC";
    };
  };
}
