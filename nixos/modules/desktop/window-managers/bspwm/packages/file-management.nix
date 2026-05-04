{ pkgs, ... }:
{
  # File management packages
  environment.systemPackages = with pkgs; [
    imagemagick
    ffmpegthumbnailer
    gnome-themes-extra
    lxqt.lxqt-policykit
  ];
}
