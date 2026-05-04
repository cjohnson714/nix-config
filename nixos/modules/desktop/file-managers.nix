{ pkgs, ... }:
{
  # Thunar file manager configuration
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

  # File management packages
  environment.systemPackages = with pkgs; [
    # File management tools
    imagemagick
    ffmpegthumbnailer
    gnome-themes-extra
    lxqt.lxqt-policykit
  ];
}
