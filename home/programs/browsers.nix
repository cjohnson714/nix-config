{
  pkgs,
  config,
  username,
  ...
}:
{
  programs = {
    firefox = {
      enable = true;
      profiles.${username} = {
        extensions.force = true;
      };
    };
    floorp = {
      enable = true;
      profiles.${username} = {
        extensions.force = true;
      };
    };

    zen-browser = {
      enable = true;
    };
  };
}
