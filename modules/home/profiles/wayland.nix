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
  config = mkIf cfg.wayland {
    home.packages = with config.nixpkgs; [
      wl-clipboard
      grim
      slurp
      swappy
    ];
  };
}
