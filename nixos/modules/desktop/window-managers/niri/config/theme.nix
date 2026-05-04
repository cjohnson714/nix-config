{ pkgs, ... }:
{
  # Niri-specific theme configuration
  imports = [ ../shared ];

  # Niri-specific theme tools
  environment.systemPackages = with pkgs; [
    nwg-look
    adw-gtk3
    kdePackages.qt6ct
  ];
}
