{
  pkgs,
  config,
  ...
}:
{
  home.file.".config/rofi" = {
    source = ./configs;
    # copy the scripts directory recursively
    recursive = true;
  };
  home.file.".local/share/rofi/themes" = {
    source = ./themes;
    recursive = true;
  };
}
