{
  pkgs,
  inputs,
  ...
}:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri"; # Or "hyprland" or "sway"
  };
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    dms-shell = {
      enable = true;
      systemd.enable = true;
      enableClipboard = true;
      enableDynamicTheming = true;
      package = pkgs.dms-shell;
    };
  };

  environment.systemPackages = with pkgs; [
    dms-shell
    adw-gtk3
    kdePackages.qt6ct
  ];
}
