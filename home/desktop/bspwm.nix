{
  pkgs,
  config,
  ...
}:
{
  # wallpaper, binary file
  home.file.".config/bspwm/wallpaper.jpg".source = ../../wallpaper.jpg;
  home.file.".config/bspwm/bspwmrc" = {
    source = ../../config/bspwm/bspwmrc;
    executable = true;
  };
  home.file.".config/sxhkd/sxhkdrc" = {
    source = ../../config/bspwm/sxhkdrc;
    executable = true;
  };
  home.file.".config/bspwm/keybindings".source = ../../config/bspwm/keybindings;
  home.file.".config/bspwm/scripts" = {
    source = ../../config/bspwm/scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true; # make all scripts executable
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 96;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintslight";
    "Xft.hinting" = "1";
    "Xft.antialias" = "1";
    "Xft.rgba" = "rgb";

    "*background" = "#1e1e2e";
    "*foreground" = "#cdd6f4";
    "*cursorColor" = "#f5e0dc";

    # Black
    "*color0" = "#45475a";
    "*color8" = "#585b70";

    # Red
    "*color1" = "#f38ba8";
    "*color9" = "#f38ba8";

    # Green
    "*color2" = "#a6e3a1";
    "*color10" = "#a6e3a1";

    # Yellow
    "*color3" = "#f9e2af";
    "*color11" = "#f9e2af";

    # Blue
    "*color4" = "#89b4fa";
    "*color12" = "#89b4fa";

    # Magenta
    "*color5" = "#f5c2e7";
    "*color13" = "#f5c2e7";

    # Cyan
    "*color6" = "#94e2d5";
    "*color14" = "#94e2d5";

    # White
    "*color7" = "#bac2de";
    "*color15" = "#a6adc8";
  };

  # enable dunst w/home-manager when using bspwm
  #services.dunst.enable = false;
}
