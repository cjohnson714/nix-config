{ pkgs, inputs, ... }:

{
  imports = [
    ../../../modules/home
  ];

  nixpkgs.overlays = [
    (import ../../../overlays/custom-packages.nix)
  ];

  programs.git.settings.user = {
    name = "cjohnson714";
    email = "cjohnson714@gmail.com";
  };
}
