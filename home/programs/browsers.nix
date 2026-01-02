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
  };
}
