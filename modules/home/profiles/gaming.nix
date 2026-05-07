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
  config = mkIf cfg.gaming {
    # Gaming packages
    home.packages = with config.nixpkgs; [
      mangohud
      gamemode
    ];
  };
}
