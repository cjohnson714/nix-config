{ pkgs, ... }:
{
  # Niri-specific packages
  environment.systemPackages = with pkgs; [
    dms-shell
    adw-gtk3
    kdePackages.qt6ct
  ];
}
