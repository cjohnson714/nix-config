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
  config = mkIf cfg.browsers {
    # Enable browsers
    programs.firefox.enable = true;
    programs.floorp.enable = true;
    programs.zen-browser.enable = true;
  };
}
