{
  pkgs,
  config,
  ...
}:
{
  programs = {
    firefox = {
      enable = true;
      profiles.${config.home.username} = {
        extensions.force = true;
      };
    };
    floorp = {
      enable = true;
      profiles.${config.home.username} = {
        extensions.force = true;
      };
    };

    zen-browser = {
      enable = true;
    };
  };
}
