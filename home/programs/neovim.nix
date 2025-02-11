{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    lunarvim
  ];

  home.file.".config/lvim/config.lua".source = ../../config/neovim/config.lua;
}
