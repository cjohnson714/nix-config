{ pkgs, ... }:
{
  # Shell programs
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
  };

  # Custom shell program
  programs."dms-shell" = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };
}
