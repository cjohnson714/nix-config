{
  pkgs,
  config,
  ...
}: {
  # wallpaper, binary file
  home.file.".config/bspwm/wallpaper.png".source = ../../wallpaper.png;
  home.file.".config/bspwm/bspwmrc" = {
    source = ./bspwmrc;
    executable = true;
  };
  home.file.".config/sxhkd/sxhkdrc" = {
    source = ./sxhkdrc;
    executable = true;
  };
  home.file.".config/bspwm/keybindings".source = ./keybindings;
  home.file.".config/bspwm/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true;  # make all scripts executable
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 96;
  };

  # enable dunst w/home-manager when using bspwm
  #services.dunst.enable = false;
}