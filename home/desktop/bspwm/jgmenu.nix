{
  pkgs,
  config,
  ...
}:
{
  home.file.".config/jgmenu" = {
    source = ../../../config/jgmenu;
    recursive = true;
  };
}
