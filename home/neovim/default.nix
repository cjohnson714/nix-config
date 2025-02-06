{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    lunarvim
  ];

  home.file.".config/lvim/config.lua".source = ./lunarvim/config.lua;
}
