{ pkgs, ... }:
{
  home.packages = [ pkgs.niri ];

  home.file.".config/niri/config.kdl".source = ./files/niri/config.kdl;
}
