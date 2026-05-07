{ pkgs, ... }:
{
  home.packages = [
    pkgs.wine
    pkgs.winetricks
  ];
}
