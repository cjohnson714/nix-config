{
  pkgs,
  config,
  ...
}:
{
  home.file.".config/rofi" = {
    source = ../../../config/rofi/configs;
    recursive = true;
  };
  home.file.".local/share/rofi/themes" = {
    source = ../../../config/rofi/themes;
    recursive = true;
  };
}
