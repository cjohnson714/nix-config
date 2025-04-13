{
  pkgs,
  config,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    # images
    imv
    ffmpeg-full
    spotify
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = [ "gpu-hq" ];
      scripts = [
        pkgs.mpvScripts.mpris
        pkgs.mpvScripts.uosc
        pkgs.mpvScripts.thumbfast
        pkgs.mpvScripts.autosubsync-mpv
      ];
    };
  };

  home.file.".config/mpv" = {
    source = ../../config/mpv;
    recursive = true;
  };

  services = {
    playerctld.enable = true;
    easyeffects.enable = true;
  };
}
