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
    programs.git = {
      enable = true;
      userName = "cjohnson714";
      userEmail = "cjohnson714@gmail.com";
    };

    home.packages = with config.nixpkgs; [
      git
      gh
      obsidian
    ];
  };
}
