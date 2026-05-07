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
  config = mkIf cfg.communication {
    home.packages = with config.nixpkgs; [
      discord
      telegram-desktop
    ];
  };
}
