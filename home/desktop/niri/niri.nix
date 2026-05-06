{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    niri
    wl-gammactl
  ];
  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/niri/config.kdl";
}
