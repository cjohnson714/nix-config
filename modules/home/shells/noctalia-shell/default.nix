{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.noctalia-shell;
in
{
  options.programs.noctalia-shell = {
    enable = mkEnableOption "Noctalia Shell - a sleek and minimal desktop shell for Wayland";

    package = mkOption {
      type = types.package;
      default = pkgs.dms-shell;
      defaultText = literalExpression "pkgs.dms-shell";
      description = "The Noctalia Shell package to use.";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to autostart Noctalia Shell on login.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Noctalia requires quickshell
    home.packages = [ pkgs.quickshell ];

    # Autostart Noctalia Shell if requested
    xdg.configFile = mkIf cfg.autoStart {
      "autostart/noctalia-shell.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Noctalia Shell
        Exec=${cfg.package}/bin/noctalia
        Comment=Sleek and minimal desktop shell for Wayland
        X-GNOME-Autostart-enabled=true
      '';
    };

    # Ensure required services are available
    services.dunst.enable = mkDefault true;
  };
}
