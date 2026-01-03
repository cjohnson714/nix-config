{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    wl-gammactl
  ];
  programs.niri.enable = true;
  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/niri/config.kdl";
}
