{ dms, ... }:
{
  # DankMaterialShell desktop configuration (Home Manager)
  # Only use the base DMS Home Manager module; Niri integration is handled
  # directly in the Niri KDL config we manage in home/desktop/niri.nix.

  imports = [
    dms.homeModules.dankMaterialShell.default
  ];

  programs.dankMaterialShell = {
    enable = true;

    # Run DMS as a systemd user service so it is available in Niri sessions
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # Turn on the main "batteries included" features
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };
}
