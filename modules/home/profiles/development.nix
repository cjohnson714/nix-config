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
  config = mkIf cfg.development {
    # Git configuration
    programs.git.enable = true;
    
    home.packages = with config.nixpkgs; [
      git
      gh
    ];

    # Git user config from base profile
    programs.git.userName = "cjohnson714";
    programs.git.userEmail = "cjohnson714@gmail.com";
  };
}
