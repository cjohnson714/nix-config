{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    eww
  ];
}
