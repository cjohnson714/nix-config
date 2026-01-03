{ pkgs, inputs, ... }:

{
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/shell
    ../../home/desktop/bspwm
    ../../home/desktop/niri
  ];

  programs.git.settings.user = {
    name = "cjohnson714";
    email = "cjohnson714@gmail.com";
  };
}
