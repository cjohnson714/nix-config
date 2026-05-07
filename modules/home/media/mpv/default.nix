{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [
      pkgs.mpvScripts.mpris
      pkgs.mpvScripts.uosc
      pkgs.mpvScripts.thumbfast
      pkgs.mpvScripts.autosubsync-mpv
    ];
  };

  home.file.".config/mpv" = {
    source = ./files/mpv;
    recursive = true;
  };
}
