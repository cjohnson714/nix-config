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
  config = mkIf cfg.files {
    programs.yazi.enable = true;

    home.packages = with config.nixpkgs; [
      fd
      ripgrep
    ];
  };
}
