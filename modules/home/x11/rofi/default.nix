{ ... }:
{
  home.file.".config/rofi" = {
    source = ./files/rofi/configs;
    recursive = true;
  };
  home.file.".local/share/rofi/themes" = {
    source = ./files/rofi/themes;
    recursive = true;
  };
}
