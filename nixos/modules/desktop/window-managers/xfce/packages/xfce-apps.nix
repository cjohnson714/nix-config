{ pkgs, ... }:
{
  # XFCE-specific packages
  environment.systemPackages = with pkgs; [
    xfce.xfce4-terminal
    xfce.thunar
    xfce.ristretto
    xfce.mousepad
  ];
}
