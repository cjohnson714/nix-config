{ pkgs, ... }:
{
  home.packages = [ pkgs.lunarvim ];

  home.file.".config/lvim/config.lua".source = ./files/neovim/config.lua;
}
