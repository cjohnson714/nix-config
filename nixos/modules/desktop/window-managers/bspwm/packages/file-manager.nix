{ pkgs, ... }:
{
  # Thunar file manager (commonly used with BSPWM)
  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    xfconf.enable = true;
  };
}
