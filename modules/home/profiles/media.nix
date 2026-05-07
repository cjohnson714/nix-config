{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.nix-config.profiles;
in
{
  config = mkIf cfg.media {
    # Enable media programs
    programs.easyeffects.enable = true;
    programs.imv.enable = true;
    programs.mpv.enable = true;
    programs.spotify.enable = true;

    # Media packages
    home.packages = with config.nixpkgs; [
      ffmpeg
      pavucontrol
      playerctl
      pulsemixer
    ];

    # Enable playerctld service
    services.playerctld.enable = true;
  };
}
