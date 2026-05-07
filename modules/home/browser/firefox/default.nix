{ config, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.${config.home.username} = {
      extensions.force = true;
    };
  };
}
