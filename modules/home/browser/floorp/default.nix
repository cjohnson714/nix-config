{ config, ... }:
{
  programs.floorp = {
    enable = true;
    profiles.${config.home.username} = {
      extensions.force = true;
    };
  };
}
