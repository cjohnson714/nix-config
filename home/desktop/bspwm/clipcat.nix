{
  pkgs,
  config,
  ...
}:
{
  home.file.".config/clipcat" = {
    source = ../../../config/clipcat;
    recursive = true;
  };
}
