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
  config = mkIf cfg.gpu {
    home.packages = with config.nixpkgs; [
      nvidia-system
    ];
  };
}
