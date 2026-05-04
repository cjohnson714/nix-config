{ pkgs, ... }:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = with pkgs; [
    dms-shell
    adw-gtk3
    kdePackages.qt6ct
  ];
}
